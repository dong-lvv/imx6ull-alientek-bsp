#ifndef VIDEOBACKEND_H
#define VIDEOBACKEND_H

#include <QObject>
#include <QProcess>
#include <QString>

class VideoBackend : public QObject
{
    Q_OBJECT
public:
    explicit VideoBackend(QObject *parent = nullptr);
    ~VideoBackend();

    // 暴露给 QML 调用的接口必须加 Q_INVOKABLE 宏
    Q_INVOKABLE void play(const QString &videoUrl);
    Q_INVOKABLE void pause();
    Q_INVOKABLE void resume();
    Q_INVOKABLE void stop();

private:
    QProcess *m_process; // 用于管理后台播放进程
    bool m_isPaused;
};

#endif // VIDEOBACKEND_H
