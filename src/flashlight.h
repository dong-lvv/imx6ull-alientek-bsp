#ifndef FLASHLIGHT_H
#define FLASHLIGHT_H

#include <QObject>
#include <fstream>
#include <string_view>

class Flashlight : public QObject {
    Q_OBJECT
    // QML 端可以绑定的属性：当前开关状态、是否处于心跳模式
    Q_PROPERTY(bool isOn READ isOn WRITE setIsOn NOTIFY isOnChanged)
    Q_PROPERTY(bool isHeartbeat READ isHeartbeat WRITE setIsHeartbeat NOTIFY isHeartbeatChanged)

public:
    explicit Flashlight(QObject *parent = nullptr);

    bool isOn() const { return m_isOn; }
    void setIsOn(bool on);

    bool isHeartbeat() const { return m_isHeartbeat; }
    void setIsHeartbeat(bool heartbeat);

signals:
    void isOnChanged();
    void isHeartbeatChanged();

private:
    bool m_isOn = false;
    bool m_isHeartbeat = false;

    // 封装向 sysfs 写入数据的通用函数
    void writeSysfs(std::string_view path, std::string_view value);
};

#endif // FLASHLIGHT_H
