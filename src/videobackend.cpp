#include "videobackend.h"
#include <QDebug>

VideoBackend::VideoBackend(QObject *parent)
    : QObject(parent), m_process(new QProcess(this)), m_isPaused(false)
{
    // 将标准输出转发，方便在 Qt Creator 里看 gstreamer 的报错
    m_process->setProcessChannelMode(QProcess::ForwardedChannels);
}

VideoBackend::~VideoBackend()
{
    stop();
}

void VideoBackend::play(const QString &videoUrl)
{
    stop(); // 播放新视频前，先停掉老的

    // 调用 gstreamer，强行指定 video-sink 为 fbdevsink (Framebuffer设备)
    QString program = "gst-launch-1.0";
    QStringList arguments;
    arguments << "playbin"
              << "uri=" + videoUrl
              << "video-sink=fbdevsink"
              << "audio-sink=fakesink";

    qDebug() << "▶️ [C++ 后端] 启动底层播放进程:" << program << arguments.join(" ");

    m_process->start(program, arguments);
    m_isPaused = false;
}

void VideoBackend::pause()
{
    if (m_process->state() == QProcess::Running && !m_isPaused) {
        qDebug() << "⏸ [C++ 后端] 发送 SIGSTOP 信号暂停进程";
        // Linux 底层魔法：直接给进程发 STOP 信号冻结它
        QString killCmd = QString("kill -STOP %1").arg(m_process->processId());
        QProcess::execute(killCmd);
        m_isPaused = true;
    }
}

void VideoBackend::resume()
{
    if (m_process->state() == QProcess::Running && m_isPaused) {
        qDebug() << "▶️ [C++ 后端] 发送 SIGCONT 信号恢复进程";
        // 发送 CONT 信号解冻进程
        QString killCmd = QString("kill -CONT %1").arg(m_process->processId());
        QProcess::execute(killCmd);
        m_isPaused = false;
    }
}

void VideoBackend::stop()
{
    if (m_process->state() != QProcess::NotRunning) {
        qDebug() << "⏹️ [C++ 后端] 杀死播放进程";
        m_process->kill();
        m_process->waitForFinished(1000);
    }
    m_isPaused = false;
}
