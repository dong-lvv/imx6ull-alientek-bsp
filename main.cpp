#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QCoreApplication> // 修复第7行报错
#include <QtQml>            // 修复第13行 qmlRegisterType 报错
#include "flashlight.h"
#include "videobackend.h"
#include "camerabackend.h"
#include "wallpaper.h"
int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    // 1. 必须先实例化 QGuiApplication！这是整个程序的大脑
    QGuiApplication app(argc, argv);

    // 2. 然后再把你的 C++ 硬件控制类注册给 QML
    qmlRegisterType<Flashlight>("MyHardware", 1, 0, "Flashlight");
    qmlRegisterType<VideoBackend>("MyOS.Backend", 1, 0, "VideoBackend");
    qmlRegisterType<CameraBackend>("MyHardware", 1, 0, "CameraBackend");
    qmlRegisterSingletonType<Wallpaper>("MyHardware", 1, 0, "Wallpaper",
        [](QQmlEngine *engine, QJSEngine *) -> QObject * {
            return new Wallpaper(engine);
        });
    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
