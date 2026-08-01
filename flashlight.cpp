#include "flashlight.h"
#include <iostream>

Flashlight::Flashlight(QObject *parent) : QObject(parent) {
    // 初始化时确保触发器处于 default 状态，并关闭 LED
    writeSysfs("/sys/class/leds/red/trigger", "none");
    writeSysfs("/sys/class/leds/red/brightness", "0");
}

void Flashlight::setIsOn(bool on) {
    if (m_isOn == on) return;

    m_isOn = on;
    // 如果处于心跳模式，强制退出心跳模式
    if (m_isHeartbeat) {
        setIsHeartbeat(false);
    }

    // 往 sysfs 节点写入亮度值
    writeSysfs("/sys/class/leds/red/brightness", on ? "1" : "0");
    emit isOnChanged();
}

void Flashlight::setIsHeartbeat(bool heartbeat) {
    if (m_isHeartbeat == heartbeat) return;

    m_isHeartbeat = heartbeat;
    // 改变触发器状态
    writeSysfs("/sys/class/leds/red/trigger", heartbeat ? "heartbeat" : "none");

    // 如果开启了心跳，逻辑上手电筒不算常亮，同步更新 UI 状态
    if (heartbeat && m_isOn) {
        m_isOn = false;
        emit isOnChanged();
    }
    emit isHeartbeatChanged();
}

void Flashlight::writeSysfs(std::string_view path, std::string_view value) {
    std::ofstream file(path.data());
    if (file.is_open()) {
        file << value;
        file.close();
    } else {
        std::cerr << "Failed to open " << path << std::endl;
    }
}
