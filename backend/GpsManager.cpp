#include "GpsManager.h"
#include <QDebug>
#include <QDateTime>

GpsManager::GpsManager(QObject *parent)
    : QObject(parent)
    , m_positionSource(nullptr)
    , m_satelliteSource(nullptr)
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
{
    qDebug() << "GpsManager: Initializing...";

    // ایجاد Position Source
    m_positionSource = QGeoPositionInfoSource::createDefaultSource(this);
    if (m_positionSource) {
        qDebug() << "GpsManager: Position source created:" << m_positionSource->sourceName();

        // تنظیمات
        m_positionSource->setUpdateInterval(1000); // بروزرسانی هر 1 ثانیه
        m_positionSource->setPreferredPositioningMethods(QGeoPositionInfoSource::AllPositioningMethods);

        // اتصال سیگنال‌ها
        connect(m_positionSource, &QGeoPositionInfoSource::positionUpdated,
                this, &GpsManager::onPositionUpdated);
        connect(m_positionSource, &QGeoPositionInfoSource::errorOccurred,
                this, &GpsManager::onPositionError);

        updateStatusMessage("GPS آماده است");
    } else {
        qWarning() << "GpsManager: Failed to create position source!";
        updateStatusMessage("خطا: منبع GPS در دسترس نیست");
        emit errorOccurred("منبع GPS در دسترس نیست");
    }

    // ایجاد Satellite Source
    m_satelliteSource = QGeoSatelliteInfoSource::createDefaultSource(this);
    if (m_satelliteSource) {
        qDebug() << "GpsManager: Satellite source created:" << m_satelliteSource->sourceName();

        // تنظیمات
        m_satelliteSource->setUpdateInterval(1000);

        // اتصال سیگنال‌ها
        connect(m_satelliteSource, &QGeoSatelliteInfoSource::satellitesInViewUpdated,
                this, &GpsManager::onSatellitesInViewUpdated);
        connect(m_satelliteSource, &QGeoSatelliteInfoSource::satellitesInUseUpdated,
                this, &GpsManager::onSatellitesInUseUpdated);
        connect(m_satelliteSource, &QGeoSatelliteInfoSource::errorOccurred,
                this, &GpsManager::onSatelliteError);
    } else {
        qWarning() << "GpsManager: Failed to create satellite source!";
    }
}

GpsManager::~GpsManager()
{
    stopUpdates();
    qDebug() << "GpsManager: Destroyed";
}

void GpsManager::startUpdates()
{
    qDebug() << "GpsManager: Starting updates...";

    if (m_positionSource) {
        m_positionSource->startUpdates();
        updateStatusMessage("در حال دریافت موقعیت...");
    }

    if (m_satelliteSource) {
        m_satelliteSource->startUpdates();
    }
}

void GpsManager::stopUpdates()
{
    qDebug() << "GpsManager: Stopping updates...";

    if (m_positionSource) {
        m_positionSource->stopUpdates();
    }

    if (m_satelliteSource) {
        m_satelliteSource->stopUpdates();
    }

    updateStatusMessage("GPS متوقف شد");
}

void GpsManager::onPositionUpdated(const QGeoPositionInfo &info)
{
    if (!info.isValid()) {
        qDebug() << "GpsManager: Received invalid position";
        return;
    }

    qDebug() << "GpsManager: Position updated";

    // موقعیت جغرافیایی
    QGeoCoordinate coord = info.coordinate();
    m_latitude = coord.latitude();
    m_longitude = coord.longitude();
    m_altitude = coord.altitude();

    // سرعت
    if (info.hasAttribute(QGeoPositionInfo::GroundSpeed)) {
        m_speed = info.attribute(QGeoPositionInfo::GroundSpeed);
    } else {
        m_speed = 0.0;
    }

    // جهت
    if (info.hasAttribute(QGeoPositionInfo::Direction)) {
        m_direction = info.attribute(QGeoPositionInfo::Direction);
    } else {
        m_direction = 0.0;
    }

    // دقت افقی
    if (info.hasAttribute(QGeoPositionInfo::HorizontalAccuracy)) {
        m_horizontalAccuracy = info.attribute(QGeoPositionInfo::HorizontalAccuracy);
    } else {
        m_horizontalAccuracy = 0.0;
    }

    // دقت عمودی
    if (info.hasAttribute(QGeoPositionInfo::VerticalAccuracy)) {
        m_verticalAccuracy = info.attribute(QGeoPositionInfo::VerticalAccuracy);
    } else {
        m_verticalAccuracy = 0.0;
    }

    // زمان
    QDateTime dt = info.timestamp();
    m_timestamp = dt.toString("yyyy-MM-dd hh:mm:ss");

    // وضعیت
    m_isValid = true;
    updateStatusMessage("موقعیت دریافت شد");

    emit positionChanged();
}

void GpsManager::onPositionError(QGeoPositionInfoSource::Error error)
{
    QString errorMsg;
    switch (error) {
    case QGeoPositionInfoSource::AccessError:
        errorMsg = "خطا: دسترسی به GPS غیرفعال است";
        break;
    case QGeoPositionInfoSource::ClosedError:
        errorMsg = "خطا: منبع GPS بسته شد";
        break;
    case QGeoPositionInfoSource::UnknownSourceError:
        errorMsg = "خطا: منبع GPS ناشناخته";
        break;
    default:
        errorMsg = "خطای ناشناخته GPS";
    }

    qWarning() << "GpsManager: Position error:" << errorMsg;
    updateStatusMessage(errorMsg);
    emit errorOccurred(errorMsg);

    resetData();
}

void GpsManager::onSatellitesInViewUpdated(const QList<QGeoSatelliteInfo> &satellites)
{
    m_satellitesInView = satellites;
    m_satelliteCount = satellites.count();

    qDebug() << "GpsManager: Satellites in view:" << m_satelliteCount;
    emit satellitesUpdated();
}

void GpsManager::onSatellitesInUseUpdated(const QList<QGeoSatelliteInfo> &satellites)
{
    m_satellitesUsed = satellites;
    m_satellitesInUse = satellites.count();

    qDebug() << "GpsManager: Satellites in use:" << m_satellitesInUse;
    emit satellitesUpdated();
}

void GpsManager::onSatelliteError(QGeoSatelliteInfoSource::Error error)
{
    QString errorMsg;
    switch (error) {
    case QGeoSatelliteInfoSource::AccessError:
        errorMsg = "خطا: دسترسی به اطلاعات ماهواره غیرفعال است";
        break;
    case QGeoSatelliteInfoSource::ClosedError:
        errorMsg = "خطا: منبع ماهواره بسته شد";
        break;
    case QGeoSatelliteInfoSource::UnknownSourceError:
        errorMsg = "خطا: منبع ماهواره ناشناخته";
        break;
    default:
        errorMsg = "خطای ناشناخته ماهواره";
    }

    qWarning() << "GpsManager: Satellite error:" << errorMsg;
}

QVariantList GpsManager::getSatellites()
{
    QVariantList result;

    // ترکیب اطلاعات ماهواره‌های دیده‌شده و استفاده‌شده
    for (const QGeoSatelliteInfo &sat : m_satellitesInView) {
        QVariantMap satMap;
        satMap["id"] = sat.satelliteIdentifier();
        satMap["system"] = static_cast<int>(sat.satelliteSystem());
        satMap["signalStrength"] = sat.signalStrength();
        satMap["elevation"] = sat.attribute(QGeoSatelliteInfo::Elevation);
        satMap["azimuth"] = sat.attribute(QGeoSatelliteInfo::Azimuth);

        // بررسی اینکه آیا این ماهواره در حال استفاده است
        bool inUse = false;
        for (const QGeoSatelliteInfo &usedSat : m_satellitesUsed) {
            if (usedSat.satelliteIdentifier() == sat.satelliteIdentifier()) {
                inUse = true;
                break;
            }
        }
        satMap["inUse"] = inUse;

        result.append(satMap);
    }

    return result;
}

void GpsManager::updateStatusMessage(const QString &message)
{
    if (m_statusMessage != message) {
        m_statusMessage = message;
        emit statusMessageChanged();
    }
}

void GpsManager::resetData()
{
    m_latitude = 0.0;
    m_longitude = 0.0;
    m_altitude = 0.0;
    m_speed = 0.0;
    m_direction = 0.0;
    m_horizontalAccuracy = 0.0;
    m_verticalAccuracy = 0.0;
    m_timestamp = "";
    m_isValid = false;

    emit positionChanged();
}
