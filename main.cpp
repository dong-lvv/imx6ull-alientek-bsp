#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QCoreApplication> // 修复第7行报错
#include <QtQml>            // 修复第13行 qmlRegisterType 报错
#include "flashlight.h"
int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    // 1. 必须先实例化 QGuiApplication！这是整个程序的大脑
    QGuiApplication app(argc, argv);

    // 2. 然后再把你的 C++ 硬件控制类注册给 QML
    qmlRegisterType<Flashlight>("MyHardware", 1, 0, "Flashlight");

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
