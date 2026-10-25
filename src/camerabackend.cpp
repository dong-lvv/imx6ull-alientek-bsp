#include "camerabackend.h"
#include <QDir>
#include <QFile>
#include <QDateTime>
#include <QTimer>

CameraBackend::CameraBackend(QObject *parent) : QObject(parent) {
    m_preview.setProgram("gst-launch-1.0");
    m_preview.setProcessChannelMode(QProcess::ForwardedErrorChannel);
}

CameraBackend::~CameraBackend() {
    stopPreview();
}

QStringList CameraBackend::previewArgs() const {
    // 必须拆成与命令行一致的独立 token：gst-launch 会对每个含空格的参数做转义，
    // 整条管线作为单个字符串传入会被当成一个元素名而报 syntax error。
    // 640x400 由 fbdevsink 居中显示：左右各留 80px、底部留 40px 给 Qt 控件（这些区域不被刷新）。
    // 传感器只支持固定分辨率（640x480 等），不能直接要求 640x400：
    // 先按 640x480 取流，再用 videoscale 缩到目标尺寸。640x400 由 fbdevsink
    // 居中显示：左右各留 80px、底部留 40px 给 Qt 控件（这些区域不被刷新）。
    return {
        "-q",
        "v4l2src", QString("device=%1").arg(m_device), "!",
        "video/x-raw,width=640,height=480", "!",
        "videoconvert", "!",
        "videoscale", "!",
        QString("video/x-raw,width=%1,height=%2")
            .arg(m_previewWidth).arg(m_previewHeight), "!",
        "fbdevsink", "sync=false"
    };
}


bool CameraBackend::startPreview() {
    if (m_preview.state() != QProcess::NotRunning)
        return true;
    m_preview.setArguments(previewArgs());
    m_preview.start();
    return m_preview.waitForStarted(2000);
}

void CameraBackend::stopPreview() {
    if (m_preview.state() == QProcess::NotRunning)
        return;
    m_preview.terminate();
    m_preview.waitForFinished(1000);
    if (m_preview.state() != QProcess::NotRunning)
        m_preview.kill();
}

void CameraBackend::setBusy(bool busy) {
    if (m_busy == busy) return;
    m_busy = busy;
    emit busyChanged();
}

void CameraBackend::capture() {
    if (m_busy) return;
    setBusy(true);

    // 释放摄像头，供 v4l2-ctl 独占抓拍
    stopPreview();

    QDir().mkpath(m_saveFolder);
    const QString stamp = QDateTime::currentDateTime().toString("yyyyMMdd_hhmmss");
    m_pendingPath = m_saveFolder + "/IMG_" + stamp + ".jpg";

    // 显式要求 MJPEG：--stream-to 默认存的是原始帧（YUYV），并非 JPEG。
    m_still.start("v4l2-ctl",
                  { "-d", m_device,
                    "--set-fmt-video=width=640,height=480,pixelformat=MJPG",
                    "--stream-mmap", "--stream-count", "1",
                    "--stream-to=" + m_pendingPath });

    // 抓拍通常 1 秒内完成；用事件循环不阻塞信号
    connect(&m_still, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this, &CameraBackend::onStillFinished, Qt::UniqueConnection);

    if (!m_still.waitForStarted(2000)) {
        emit failed("无法启动 v4l2-ctl");
        setBusy(false);
        startPreview();
    }
}

void CameraBackend::onStillFinished(int code, QProcess::ExitStatus status) {
    const bool ok = (status == QProcess::NormalExit && code == 0
                     && QFile::exists(m_pendingPath));
    if (ok)
        emit saved(m_pendingPath);
    else
        emit failed("抓拍失败，请重试");

    setBusy(false);
    // 稍等片刻让设备释放，再恢复预览
    QTimer::singleShot(150, this, [this] { startPreview(); });
}
