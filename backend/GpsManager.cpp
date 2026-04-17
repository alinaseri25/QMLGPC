#include "GpsManager.h"

// ------- GLOBAL POINTER -------
static GpsManager* g_mainWindowInstance = nullptr;

#ifdef Q_OS_ANDROID
extern "C"
    JNIEXPORT void JNICALL
    Java_org_verya_QMLGPC_TestBridge_onMessageFromKotlin(JNIEnv* env, jclass /*clazz*/, jstring msg)
{
    if (!g_mainWindowInstance)
        return;

    QString qmsg = QJniObject(msg).toString();

    // 🧵 انتقال امن به Thread اصلی UI با Qt
    QMetaObject::invokeMethod(g_mainWindowInstance, [=]() {
        //g_mainWindowInstance->showMessageBox(QStringLiteral("From Kotlin: %1").arg(qmsg));
        qDebug() << QStringLiteral("From Kotlin: %1").arg(qmsg);
    }, Qt::QueuedConnection);
}

extern "C"
    JNIEXPORT void JNICALL
    Java_org_verya_QMLGPC_TestBridge_nativeOnNotificationAction(JNIEnv *, jclass /*clazz*/, jstring msg)
{
    if (!g_mainWindowInstance)
        return;

    QString qmsg = QJniObject(msg).toString();
    // qDebug() << QString("Entered this point by %1").arg(qmsg);

    QMetaObject::invokeMethod(g_mainWindowInstance, [=]() {
        if(qmsg == "start")
        {
            g_mainWindowInstance->startUpdates();
            //qDebug() << QStringLiteral("start pressed");
        }
        else if(qmsg == "stop")
        {
            g_mainWindowInstance->stopUpdates();
            //qDebug() << QStringLiteral("stop pressed");
        }
    }, Qt::QueuedConnection);
}
#endif

GpsManager::GpsManager(QObject *parent)
    : QObject(parent)
    , m_positionSource(nullptr)
    , m_satelliteSource(nullptr)
    , m_mockTimer(new QTimer(this))
    , m_mockSatelliteTimer(new QTimer(this))
    , m_latitude(0.0)
    , m_longitude(0.0)
    , m_altitude(0.0)
    , m_speed(0.0)
    , m_direction(0.0)
    , m_horizontalAccuracy(0.0)
    , m_verticalAccuracy(0.0)
    , m_isValid(false)
    , m_satelliteCount(0)
    , m_satellitesInUse(0)
    , m_useMockData(false)
{
    g_mainWindowInstance = this;
    setStatusMessage("آماده برای دریافت موقعیت GPS");
    updateNotification("GPS Ready","GPS ready to start");

    // Mock Timer برای Position
    connect(m_mockTimer, &QTimer::timeout, this, &GpsManager::updateMockData);

    // Mock Timer برای Satellites
    connect(m_mockSatelliteTimer, &QTimer::timeout, this, &GpsManager::updateMockSatellites);
    compass = new QCompass(this);
    hasCompass = !QSensor::sensorsForType(QCompass::sensorType).isEmpty();//compass->connectToBackend();
    if(hasCompass)
    {
        connect(compass,&QCompass::readingChanged,this,&GpsManager::onReadingChanged);
        compass->start();
        qDebug() << "read Direction From Compass Sensor";
    }
    else
    {
        setStatusMessage(QString("دستگاه شما فاقد سنسور قطب نماست"));
        qDebug() << "read Direction From GPS Sensor";
        updateNotification("Compass Sensor","دستگاه شما فاقد سنسور قطب نماست",true);
    }
#ifdef Q_OS_ANDROID
    QJniObject jMsg = QJniObject::fromString("Hello From C++");

    QJniObject::callStaticMethod<void>(
        cls,
        "notifyCPlusPlus",
        "(Ljava/lang/String;)V",
        jMsg.object<jstring>()
        );

    QJniObject context = QNativeInterface::QAndroidApplication::context();
    if (!context.isValid())
        return;

    QJniObject::callStaticMethod<void>(
        "org/verya/QMLGPC/MainActivity",
        "manageScreenAndWakeLock",
        "(Landroid/content/Context;ZZ)V",
        context.object(),
        (jboolean)true,  // screenAlwaysOn
        (jboolean)true    // wakeLock
        );

    QJniObject::callStaticMethod<void>(
        "org/verya/QMLGPC/MainActivity",
        "setDimTimeoutFromQt",
        "(J)V",
        0
        );
#endif
}

GpsManager::~GpsManager()
{
    stopUpdates();
}

void GpsManager::setUseMockData(bool use)
{
    if (m_useMockData != use) {
        m_useMockData = use;
        emit useMockDataChanged();
        qDebug() << "🔧 Mock Data Mode:" << (use ? "ENABLED" : "DISABLED");
    }
}

void GpsManager::startUpdates()
{
    if (m_useMockData) {
        qDebug() << "🎭 Starting MOCK GPS updates...";
        setStatusMessage("حالت تست - داده‌های شبیه‌سازی شده");
        updateNotification("GPS MOCK","حالت تست - داده‌های شبیه‌سازی شده",true);
        updateValidity(true);
        m_mockTimer->start(2000);
        m_mockSatelliteTimer->start(3000);
        generateMockSatellites();
        updateMockData();
        updateMockSatellites();
        emit stateChanged(2);
        return;
    }

    // Real GPS Mode
    if (!m_positionSource) {
        m_positionSource = QGeoPositionInfoSource::createDefaultSource(this);
    }

    if (m_positionSource) {
        connect(m_positionSource, &QGeoPositionInfoSource::positionUpdated,
                this, &GpsManager::onPositionUpdated);
        connect(m_positionSource, &QGeoPositionInfoSource::errorOccurred,
                this, &GpsManager::onError);

        m_positionSource->setUpdateInterval(1000);
        m_positionSource->startUpdates();
        setStatusMessage("در حال جستجوی سیگنال GPS...");
        qDebug() << "📡 Real GPS started";
    } else {
        setStatusMessage("خطا: سرویس GPS در دسترس نیست");
        qDebug() << "❌ No GPS source available";
    }

    // Satellite Source
    if (!m_satelliteSource) {
        m_satelliteSource = QGeoSatelliteInfoSource::createDefaultSource(this);
    }

    if (m_satelliteSource) {
        connect(m_satelliteSource, &QGeoSatelliteInfoSource::satellitesInViewUpdated,
                this, &GpsManager::onSatellitesInViewUpdated);
        connect(m_satelliteSource, &QGeoSatelliteInfoSource::satellitesInUseUpdated,
                this, &GpsManager::onSatellitesInUseUpdated);

        m_satelliteSource->startUpdates();
        qDebug() << "🛰️ Satellite source started";
    }
    emit stateChanged(1);
    updateNotification("GPS State Changed","در حال جست و جوی سیگنال GPS",true);
}

void GpsManager::stopUpdates()
{
    m_mockTimer->stop();
    m_mockSatelliteTimer->stop();

    if (m_positionSource) {
        m_positionSource->stopUpdates();
    }
    if (m_satelliteSource) {
        m_satelliteSource->stopUpdates();
    }

    updateValidity(false);
    setStatusMessage("GPS متوقف شد");
    qDebug() << "🛑 GPS stopped";
    emit stateChanged(0);
    updateNotification("GPS State Changed","توقف جست و جوی GPS");
    state = false;
}

void GpsManager::onPositionUpdated(const QGeoPositionInfo &info)
{
    if((m_isValid == true) && (state != true))
    {
        state = true;
        emit stateChanged(2);
        updateNotification("GPS State Changed","موقعیت شما پیدا شد در حال بروز رسانی هستیم");
    }
    if (info.isValid()) {
        m_latitude = info.coordinate().latitude();
        m_longitude = info.coordinate().longitude();
        m_altitude = info.coordinate().altitude();
        m_speed = info.attribute(QGeoPositionInfo::GroundSpeed);
        if(hasCompass)
        {
            onReadingChanged();
        }
        else
        {
            m_direction = info.attribute(QGeoPositionInfo::Direction);
        }
        m_horizontalAccuracy = info.attribute(QGeoPositionInfo::HorizontalAccuracy);
        m_verticalAccuracy = info.attribute(QGeoPositionInfo::VerticalAccuracy);
        m_timestamp = info.timestamp().toString("yyyy-MM-dd HH:mm:ss");

        updateValidity(true);
        setStatusMessage("موقعیت دریافت شد");
        emit positionChanged();

        qDebug() << "📍 Position:" << m_latitude << "," << m_longitude;
    }
}

void GpsManager::onUpdateTimeout()
{
    setStatusMessage("زمان انتظار تمام شد - در حال تلاش مجدد...");
    qDebug() << "⏱️ GPS update timeout";
}

void GpsManager::onError(QGeoPositionInfoSource::Error error)
{
    QString errorMsg;
    switch (error) {
    case QGeoPositionInfoSource::AccessError:
        errorMsg = "خطا: دسترسی به GPS مجاز نیست";
        break;
    case QGeoPositionInfoSource::ClosedError:
        errorMsg = "خطا: اتصال GPS قطع شد";
        break;
    case QGeoPositionInfoSource::NoError:
        return;
    default:
        errorMsg = "خطا: مشکل نامشخص در GPS";
    }

    setStatusMessage(errorMsg);
    updateValidity(false);
    updateNotification("GPS Error",QString("خطای زیر پیش آمد \r\n%1").arg(errorMsg),true);
    qDebug() << "❌ GPS Error:" << errorMsg;
}

void GpsManager::onSatellitesInViewUpdated(const QList<QGeoSatelliteInfo> &satellites)
{
    m_satellitesInView = satellites;
    m_satelliteCount = satellites.count();
    emit satellitesUpdated();
    qDebug() << "🛰️ Satellites in view:" << m_satelliteCount;
}

void GpsManager::onSatellitesInUseUpdated(const QList<QGeoSatelliteInfo> &satellites)
{
    m_satellitesInUseList = satellites;
    m_satellitesInUse = satellites.count();
    emit satellitesUpdated();
    qDebug() << "✅ Satellites in use:" << m_satellitesInUse;
}

QVariantList GpsManager::getSatellites() const
{
    if (m_useMockData) {
        return m_mockSatellites;
    }

    QVariantList result;
    QSet<int> inUseIds;

    for (const auto &sat : m_satellitesInUseList) {
        inUseIds.insert(sat.satelliteIdentifier());
    }

    for (const auto &sat : m_satellitesInView) {
        QVariantMap satData;
        satData["id"] = sat.satelliteIdentifier();
        satData["signalStrength"] = sat.attribute(QGeoSatelliteInfo::Elevation);
        satData["system"] = static_cast<int>(sat.satelliteSystem());
        satData["inUse"] = inUseIds.contains(sat.satelliteIdentifier());
        result.append(satData);
    }

    return result;
}

void GpsManager::generateMockSatellites()
{
    m_mockSatellites.clear();

    // ساختن 12 ماهواره فیک با سیستم‌های مختلف
    QList<int> systems = {0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 5}; // GPS, GLONASS, Galileo, BeiDou, QZSS, NavIC

    for (int i = 0; i < 12; i++) {
        QVariantMap sat;
        sat["id"] = i + 1;

        // تولید عدد تصادفی بین 15 تا 50 (کست به int)
        int signalMin = 15;
        int signalMax = 50;
        double randomSignal = signalMin + (QRandomGenerator::global()->bounded(signalMax - signalMin));

        sat["signalStrength"] = randomSignal;
        sat["system"] = systems[i];
        sat["inUse"] = (i % 3 != 0); // هر 3 تا یکی غیرفعال
        m_mockSatellites.append(sat);
    }

    m_satelliteCount = 12;
    m_satellitesInUse = 8;

    qDebug() << "🎭 Generated" << m_mockSatellites.size() << "mock satellites";
    emit satellitesUpdated();
}

void GpsManager::acquireMulticastLock()
{
#ifdef Q_OS_ANDROID
    QJniObject context = QNativeInterface::QAndroidApplication::context();
    if (!context.isValid())
        return;

    // wake lock
    QJniObject pm = context.callObjectMethod(
        "getSystemService",
        "(Ljava/lang/String;)Ljava/lang/Object;",
        QJniObject::fromString("power").object<jstring>()
        );
    g_wakeLock = pm.callObjectMethod(
        "newWakeLock",
        "(ILjava/lang/String;)Landroid/os/PowerManager$WakeLock;",
        1, QJniObject::fromString("MyWakeLock").object<jstring>()
        );
    g_wakeLock.callMethod<void>("acquire");
#endif
}

void GpsManager::updateNotification(QString Tittle, QString Text, bool alert)
{
#ifdef Q_OS_ANDROID
    QJniObject context = QNativeInterface::QAndroidApplication::context();
    if (!context.isValid())
        return;

    int notifyId = 2025;
    QJniObject jTitle = QJniObject::fromString(Tittle);
    QJniObject jMsg   = QJniObject::fromString(Text);

    QJniObject::callStaticMethod<void>(
        cls,
        "postNotification",
        "(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;IZ)V",
        context.object(),
        jTitle.object<jstring>(),
        jMsg.object<jstring>(),
        notifyId,
        alert);
#endif
}

void GpsManager::updateMockSatellites()
{
    // بروزرسانی سیگنال ماهواره‌ها (شبیه‌سازی تغییرات)
    for (int i = 0; i < m_mockSatellites.size(); i++) {
        QVariantMap sat = m_mockSatellites[i].toMap();
        double currentSignal = sat["signalStrength"].toDouble();

        // تغییر تصادفی کوچک در سیگنال (-3 تا +3)
        int changeAmount = QRandomGenerator::global()->bounded(7) - 3; // 0 to 6, then -3 = -3 to +3
        double change = static_cast<double>(changeAmount);
        double newSignal = qBound(10.0, currentSignal + change, 50.0);

        sat["signalStrength"] = newSignal;
        m_mockSatellites[i] = sat;
    }

    qDebug() << "🔄 Mock satellites updated";
    emit satellitesUpdated();
}

void GpsManager::onReadingChanged()
{
    double tDirection;
    QCompassReading *reading = compass->reading();
    tDirection = reading->azimuth();
    if(tDirection != m_direction)
    {
        m_direction = tDirection;
        emit positionChanged();
    }
    if(reading->calibrationLevel() < 0.7)
    {
        setStatusMessage("لطفا قطب نمای خود را کالیبره کنید");
    }
}

void GpsManager::onCopyGeoData()
{
    if(m_isValid)
    {
        QClipboard *clipBoard = QGuiApplication::clipboard();
        clipBoard->setText("Hello Word Test");

        QString Str = QString("http://www.google.com/maps/place/%1,%2/@%1,%2,30z/data=!3m1!1e3/")
                          .arg(m_latitude).arg(m_longitude);
        Str += QString("\nHAC:%1").arg(m_horizontalAccuracy);
        Str += QString("\nHight:%1").arg(m_altitude);
        Str += QString("\nGSPeed:%1 K/H").arg(m_speed);
        Str += QString("\nDir:%1").arg(m_direction);
        clipBoard->clear();
        clipBoard->setText(Str);
        setStatusMessage(QString("مختصات در clipboard قرار گرفت"));
    }
    else
    {
        setStatusMessage(QString("مختصات در دسترس نیست"));
    }

}

void GpsManager::updateMockData()
{
    static double mockLat = 35.6892;
    static double mockLon = 51.3890;
    static double mockAlt = 1200.0;
    static double mockSpeed = 0.0;
    static double mockDir = 0.0;

    // شبیه‌سازی حرکت
    int latChange = QRandomGenerator::global()->bounded(200) - 100; // -100 to +100
    int lonChange = QRandomGenerator::global()->bounded(200) - 100;

    mockLat += latChange / 1000000.0;
    mockLon += lonChange / 1000000.0;

    // سرعت بین 0 تا 5
    mockSpeed = static_cast<double>(QRandomGenerator::global()->bounded(6)); // 0-5

    // جهت بین 0 تا 360
    mockDir = static_cast<double>(QRandomGenerator::global()->bounded(361)); // 0-360

    m_latitude = mockLat;
    m_longitude = mockLon;
    m_altitude = mockAlt;
    m_speed = mockSpeed;
    m_direction = mockDir;

    // دقت افقی بین 5 تا 15
    m_horizontalAccuracy = 5.0 + static_cast<double>(QRandomGenerator::global()->bounded(11));

    // دقت عمودی بین 8 تا 23
    m_verticalAccuracy = 8.0 + static_cast<double>(QRandomGenerator::global()->bounded(16));

    m_timestamp = QDateTime::currentDateTime().toString("yyyy-MM-dd HH:mm:ss");

    emit positionChanged();

    qDebug() << "🎭 Mock GPS Update:";
    qDebug() << "   📍 Position:" << m_latitude << "," << m_longitude;
    qDebug() << "   🛰️ Satellites:" << m_satelliteCount << "visible," << m_satellitesInUse << "in use";
}

void GpsManager::setStatusMessage(const QString &message)
{
    if (m_statusMessage != message) {
        m_statusMessage = message;
        emit statusMessageChanged();
    }
}

void GpsManager::updateValidity(bool valid)
{
    if (m_isValid != valid) {
        m_isValid = valid;
        emit validityChanged();
    }
}
