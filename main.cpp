#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "backend/GpsManager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // ایجاد GpsManager
    GpsManager *gpsManager = new GpsManager;

    // ایجاد QML Engine
    QQmlApplicationEngine engine;

    // 🆕 اضافه کردن مسیر Import برای Theme
    engine.addImportPath("qrc:/qt/qml");
    engine.addImportPath(":/qt/qml");

    // تزریق GpsManager به QML
    engine.rootContext()->setContextProperty("gpsManager", gpsManager);

    // لود از Module
    engine.loadFromModule("QMLGPC", "Main");

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
