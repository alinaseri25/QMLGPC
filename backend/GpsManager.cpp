#include "GpsManager.h"
#include <QDebug>
#include <QDateTime>
#include <QtMath>
#include <QRandomGenerator>

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
    setStatusMessage("آماده برای دریافت موقعیت GPS");

    // Mock Timer برای Position
    connect(m_mockTimer, &QTimer::timeout, this, &GpsManager::updateMockData);

    // Mock Timer برای Satellites
    connect(m_mockSatelliteTimer, &QTimer::timeout, this, &GpsManager::updateMockSatellites);
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
        updateValidity(true);
        m_mockTimer->start(2000);
        m_mockSatelliteTimer->start(3000);
        generateMockSatellites();
        updateMockData();
        updateMockSatellites();
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
}

void GpsManager::onPositionUpdated(const QGeoPositionInfo &info)
{
    if (info.isValid()) {
        m_latitude = info.coordinate().latitude();
        m_longitude = info.coordinate().longitude();
        m_altitude = info.coordinate().altitude();
        m_speed = info.attribute(QGeoPositionInfo::GroundSpeed);
        m_direction = info.attribute(QGeoPositionInfo::Direction);
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
