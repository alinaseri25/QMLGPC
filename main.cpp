#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "backend/GpsManager.h"

#ifdef Q_OS_ANDROID
#include <QtCore/private/qandroidextras_p.h>
#include <QPermission>

void requestLocationPermissions() {
    QLocationPermission permission;
    permission.setAccuracy(QLocationPermission::Precise);

    switch (qApp->checkPermission(permission)) {
    case Qt::PermissionStatus::Undetermined:
        qApp->requestPermission(permission, [](const QPermission &permission) {
            if (qApp->checkPermission(permission) == Qt::PermissionStatus::Granted) {
                qDebug() << "Location permission granted!";
            } else {
                qDebug() << "Location permission denied!";
            }
        });
        break;
    case Qt::PermissionStatus::Denied:
        qDebug() << "Location permission denied!";
        break;
    case Qt::PermissionStatus::Granted:
        qDebug() << "Location permission already granted!";
        break;
    }
}
#endif

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

#ifdef Q_OS_ANDROID
    requestLocationPermissions();
#endif

    GpsManager gpsManager;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("gpsManager", &gpsManager);

    const QUrl url(QStringLiteral("qrc:/qt/qml/QMLGPC/Main.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection
        );
    engine.load(url);

    return app.exec();
}
