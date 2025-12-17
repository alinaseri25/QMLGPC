#ifndef GPSMANAGER_H
#define GPSMANAGER_H

#include <QObject>
#include <QGeoSatelliteInfoSource>
#include <QGeoPositionInfo>
#include <QGeoSatelliteInfo>
#include <QVariantList>
#include <QTimer>
#include <QGeoPositionInfo>
#include <QGeoPositionInfoSource>

class GpsManager : public QObject
{
    Q_OBJECT

    // موقعیت جغرافیایی
    Q_PROPERTY(double latitude READ latitude NOTIFY positionChanged)
    Q_PROPERTY(double longitude READ longitude NOTIFY positionChanged)
    Q_PROPERTY(double altitude READ altitude NOTIFY positionChanged)

    // سرعت و جهت
    Q_PROPERTY(double speed READ speed NOTIFY positionChanged)
    Q_PROPERTY(double direction READ direction NOTIFY positionChanged)

    // دقت
    Q_PROPERTY(double horizontalAccuracy READ horizontalAccuracy NOTIFY positionChanged)
    Q_PROPERTY(double verticalAccuracy READ verticalAccuracy NOTIFY positionChanged)

    // زمان
    Q_PROPERTY(QString timestamp READ timestamp NOTIFY positionChanged)

    // وضعیت
    Q_PROPERTY(bool isValid READ isValid NOTIFY positionChanged)
    Q_PROPERTY(QString statusMessage READ statusMessage NOTIFY statusMessageChanged)

    // ماهواره‌ها
    Q_PROPERTY(int satelliteCount READ satelliteCount NOTIFY satellitesUpdated)
    Q_PROPERTY(int satellitesInUse READ satellitesInUse NOTIFY satellitesUpdated)

public:
    explicit GpsManager(QObject *parent = nullptr);
    ~GpsManager();

    // Getters
    double latitude() const { return m_latitude; }
    double longitude() const { return m_longitude; }
    double altitude() const { return m_altitude; }
    double speed() const { return m_speed; }
    double direction() const { return m_direction; }
    double horizontalAccuracy() const { return m_horizontalAccuracy; }
    double verticalAccuracy() const { return m_verticalAccuracy; }
    QString timestamp() const { return m_timestamp; }
    bool isValid() const { return m_isValid; }
    QString statusMessage() const { return m_statusMessage; }
    int satelliteCount() const { return m_satelliteCount; }
    int satellitesInUse() const { return m_satellitesInUse; }

    // متدهای قابل فراخوانی از QML
    Q_INVOKABLE void startUpdates();
    Q_INVOKABLE void stopUpdates();
    Q_INVOKABLE QVariantList getSatellites();

signals:
    void positionChanged();
    void satellitesUpdated();
    void statusMessageChanged();
    void errorOccurred(const QString &error);

private slots:
    void onPositionUpdated(const QGeoPositionInfo &info);
    void onPositionError(QGeoPositionInfoSource::Error error);
    void onSatellitesInViewUpdated(const QList<QGeoSatelliteInfo> &satellites);
    void onSatellitesInUseUpdated(const QList<QGeoSatelliteInfo> &satellites);
    void onSatelliteError(QGeoSatelliteInfoSource::Error error);

private:
    // منابع Qt Positioning
    QGeoPositionInfoSource *m_positionSource;
    QGeoSatelliteInfoSource *m_satelliteSource;

    // داده‌های موقعیت
    double m_latitude;
    double m_longitude;
    double m_altitude;
    double m_speed;
    double m_direction;
    double m_horizontalAccuracy;
    double m_verticalAccuracy;
    QString m_timestamp;
    bool m_isValid;
    QString m_statusMessage;

    // داده‌های ماهواره
    int m_satelliteCount;
    int m_satellitesInUse;
    QList<QGeoSatelliteInfo> m_satellitesInView;
    QList<QGeoSatelliteInfo> m_satellitesUsed;

    // متدهای کمکی
    void updateStatusMessage(const QString &message);
    void resetData();
};

#endif // GPSMANAGER_H
