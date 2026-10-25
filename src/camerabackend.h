#ifndef CAMERABACKEND_H
#define CAMERABACKEND_H

#include <QObject>
#include <QProcess>
#include <QString>

// 通过 QProcess 驱动板子上已验证可用的 GStreamer / v4l2-ctl，
// 避免依赖 Qt Multimedia 相机服务（该 Qt 未编译 GStreamer 后端）。
class CameraBackend : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)
    Q_PROPERTY(QString device READ device WRITE setDevice)
    Q_PROPERTY(QString saveFolder READ saveFolder WRITE setSaveFolder)
    // 预览输出尺寸：fbdevsink 始终居中显示，缩小高度可在屏幕上/下方留出不被刷新的区域
    Q_PROPERTY(int previewWidth READ previewWidth WRITE setPreviewWidth)
    Q_PROPERTY(int previewHeight READ previewHeight WRITE setPreviewHeight)

public:
    explicit CameraBackend(QObject *parent = nullptr);
    ~CameraBackend() override;

    bool busy() const { return m_busy; }

    QString device() const { return m_device; }
    void setDevice(const QString &device) { m_device = device; }

    QString saveFolder() const { return m_saveFolder; }
    void setSaveFolder(const QString &folder) { m_saveFolder = folder; }

    int previewWidth() const { return m_previewWidth; }
    void setPreviewWidth(int width) { m_previewWidth = width; }

    int previewHeight() const { return m_previewHeight; }
    void setPreviewHeight(int height) { m_previewHeight = height; }

    // 启动/停止全屏预览（gst-launch + fbdevsink）
    Q_INVOKABLE bool startPreview();
    Q_INVOKABLE void stopPreview();

    // 拍照：停预览 -> v4l2-ctl 抓一帧 -> 重启预览
    Q_INVOKABLE void capture();

signals:
    void busyChanged();
    void saved(const QString &path);
    void failed(const QString &message);

private slots:
    void onStillFinished(int code, QProcess::ExitStatus status);

private:
    QProcess m_preview;
    QProcess m_still;
    bool m_busy = false;
    QString m_device = "/dev/video1";
    QString m_saveFolder = "/home/lv/photos";
    int m_previewWidth = 640;
    int m_previewHeight = 480;
    QString m_pendingPath;

    void setBusy(bool busy);
    QStringList previewArgs() const;
};

#endif // CAMERABACKEND_H
