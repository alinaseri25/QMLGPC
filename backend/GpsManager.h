#ifndef GPSMANAGER_H
#define GPSMANAGER_H

#include <QObject>
#include <QGeoPositionInfoSource>
#include <QGeoPositionInfo>
#include <QGeoSatelliteInfoSource>
#include <QGeoSatelliteInfo>
#include <QTimer>
#include <QVariantList>

class GpsManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(double latitude READ latitude NOTIFY positionChanged)
    Q_PROPERTY(double longitude READ longitude NOTIFY positionChanged)
    Q_PROPERTY(double altitude READ altitude NOTIFY positionChanged)
    Q_PROPERTY(double speed READ speed NOTIFY positionChanged)
    Q_PROPERTY(double direction READ direction NOTIFY positionChanged)
    Q_PROPERTY(double horizontalAccuracy READ horizontalAccuracy NOTIFY positionChanged)
    Q_PROPERTY(double verticalAccuracy READ verticalAccuracy NOTIFY positionChanged)
    Q_PROPERTY(QString timestamp READ timestamp NOTIFY positionChanged)
    Q_PROPERTY(bool isValid READ isValid NOTIFY validityChanged)
    Q_PROPERTY(QString statusMessage READ statusMessage NOTIFY statusMessageChanged)
    Q_PROPERTY(int satelliteCount READ satelliteCount NOTIFY satellitesUpdated)
    Q_PROPERTY(int satellitesInUse READ satellitesInUse NOTIFY satellitesUpdated)
    Q_PROPERTY(bool useMockData READ useMockData WRITE setUseMockData NOTIFY useMockDataChanged)

public:
    explicit GpsManager(QObject *parent = nullptr);
    ~GpsManager();

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
    bool useMockData() const { return m_useMockData; }

    void setUseMockData(bool use);

    Q_INVOKABLE void startUpdates();
    Q_INVOKABLE void stopUpdates();
    Q_INVOKABLE QVariantList getSatellites() const;

signals:
    void positionChanged();
    void validityChanged();
    void statusMessageChanged();
    void satellitesUpdated();
    void useMockDataChanged();

private slots:
    void onPositionUpdated(const QGeoPositionInfo &info);
    void onUpdateTimeout();
    void onError(QGeoPositionInfoSource::Error error);
    void onSatellitesInViewUpdated(const QList<QGeoSatelliteInfo> &satellites);
    void onSatellitesInUseUpdated(const QList<QGeoSatelliteInfo> &satellites);
    void updateMockData();
    void updateMockSatellites();

private:
    QGeoPositionInfoSource *m_positionSource;
    QGeoSatelliteInfoSource *m_satelliteSource;
    QTimer *m_mockTimer;
    QTimer *m_mockSatelliteTimer;

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
    int m_satelliteCount;
    int m_satellitesInUse;
    bool m_useMockData;

    QList<QGeoSatelliteInfo> m_satellitesInView;
    QList<QGeoSatelliteInfo> m_satellitesInUseList;
    QVariantList m_mockSatellites;

    void setStatusMessage(const QString &message);
    void updateValidity(bool valid);
    void generateMockSatellites();
};

#endif // GPSMANAGER_H
