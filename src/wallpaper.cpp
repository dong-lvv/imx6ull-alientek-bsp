#include "wallpaper.h"
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QTextStream>
#include <QDebug>

Wallpaper::Wallpaper(QObject *parent) : QObject(parent) {
    // 用固定绝对路径，避免板子上 HOME 未设置/不一致导致重启后读不到。
    // 与照片目录同处 /home/lv，该路径已验证可写。
    m_configFile = "/home/lv/.mxui_wallpaper";
    load();
}

void Wallpaper::load() {
    QFile f(m_configFile);
    if (f.open(QIODevice::ReadOnly | QIODevice::Text)) {
        m_path = QString::fromUtf8(f.readAll()).trimmed();
        f.close();
        qWarning() << "[Wallpaper] loaded ->" << m_path;
    } else {
        qWarning() << "[Wallpaper] no config at" << m_configFile;
    }
}

void Wallpaper::setPath(const QString &path) {
    if (m_path == path) return;
    m_path = path;

    // 确保目录存在
    QDir().mkpath(QFileInfo(m_configFile).absolutePath());

    QFile f(m_configFile);
    if (f.open(QIODevice::WriteOnly | QIODevice::Truncate | QIODevice::Text)) {
        QTextStream out(&f);
        out << path;
        out.flush();
        f.close();
        if (f.error() != QFile::NoError)
            qWarning() << "[Wallpaper] write error:" << f.errorString();
        else
            qWarning() << "[Wallpaper] saved ->" << path << "to" << m_configFile;
    } else {
        qWarning() << "[Wallpaper] cannot open for write:" << m_configFile
                   << f.errorString();
    }

    emit pathChanged();
}
