#ifndef WALLPAPER_H
#define WALLPAPER_H

#include <QObject>
#include <QString>

// 记录并持久化当前桌面壁纸路径，供桌面背景与壁纸 App 共享。
class Wallpaper : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString path READ path WRITE setPath NOTIFY pathChanged)

public:
    explicit Wallpaper(QObject *parent = nullptr);

    QString path() const { return m_path; }
    void setPath(const QString &path);

signals:
    void pathChanged();

private:
    QString m_path;
    QString m_configFile;

    void load();
};

#endif // WALLPAPER_H
