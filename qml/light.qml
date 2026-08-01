import QtQuick 2.14
import QtQuick.Controls 2.14
import MyHardware 1.0 // 引入我们刚刚注册的 C++ 模块

Rectangle {
    id: lightApp
    anchors.fill: parent
    // 动态背景：开启手电筒时背景变亮，关闭时保持深色
    color: hardwareLight.isOn ? "#2C3E50" : "#1A1A1A"

    // 实例化底层的 C++ 对象
    Flashlight {
        id: hardwareLight
    }

    // --- 顶部导航栏 (用于退出 App) ---
    Rectangle {
        id: navBar
        anchors.top: parent.top
        width: parent.width
        height: 50
        color: "transparent"
        z: 10

        Button {
            anchors.left: parent.left
            anchors.leftMargin: 15
            anchors.verticalCenter: parent.verticalCenter
            text: "◁ 返回"
            background: Item {}
            contentItem: Text {
                text: parent.text
                color: "white"
                font.pixelSize: 16
            }
            onClicked: {
                // 退出应用前，为了省电，默认关灯并关闭心跳
                hardwareLight.isOn = false
                hardwareLight.isHeartbeat = false
                appWindowLoader.closeApp()
            }
        }
    }

    // --- 中心巨型电源按钮 ---
    Rectangle {
        id: powerButton
        width: 200
        height: 200
        radius: 100
        anchors.centerIn: parent
        // 根据状态切换按钮颜色
        color: hardwareLight.isOn ? "#F1C40F" : "#34495E"
        border.color: hardwareLight.isOn ? "#F39C12" : "#2C3E50"
        border.width: 5

        Text {
            anchors.centerIn: parent
            text: "⏻" // 电源符号
            font.pixelSize: 80
            color: hardwareLight.isOn ? "white" : "#7F8C8D"
        }

        MouseArea {
            anchors.fill: parent
            onPressed: parent.scale = 0.95
            onReleased: parent.scale = 1.0
            onClicked: {
                // 直接修改 C++ 暴露的属性，后端会自动写入 sysfs
                hardwareLight.isOn = !hardwareLight.isOn
            }
            // 添加动画让缩放更平滑
            Behavior on scale { NumberAnimation { duration: 100 } }
        }
    }

    // --- 底部：心跳模式开关 ---
    Row {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 40
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 15

        Text {
            text: "SOS 心跳模式"
            color: "white"
            font.pixelSize: 18
            anchors.verticalCenter: parent.verticalCenter
        }

        Switch {
            id: heartbeatSwitch
            anchors.verticalCenter: parent.verticalCenter
            // 绑定 C++ 属性
            checked: hardwareLight.isHeartbeat
            onCheckedChanged: {
                if (checked !== hardwareLight.isHeartbeat) {
                    hardwareLight.isHeartbeat = checked
                }
            }
        }
    }
}
