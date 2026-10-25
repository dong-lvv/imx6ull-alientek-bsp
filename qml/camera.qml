import QtQuick 2.14
import QtQuick.Controls 2.14
import MyHardware 1.0

Rectangle {
    id: cameraApp
    anchors.fill: parent
    color: "#000000"

    CameraBackend {
        id: cam
        device: "/dev/video1"
        saveFolder: "/home/lv/photos"

        onSaved: {
            statusLabel.text = "✓ 已保存"
            statusTimer.restart()
        }
        onFailed: {
            statusLabel.text = "✗ 失败"
            statusTimer.restart()
        }
    }

    // 进入即开始全屏预览（640x480 居中，x=80..720）
    Component.onCompleted: cam.startPreview()

    // ===== 左侧栏：返回（0..80，视频不刷新此区域）=====
    Item {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 80

        Text {
            id: backText
            anchors.left: parent.left
            anchors.leftMargin: 18
            anchors.top: parent.top
            anchors.topMargin: 16
            text: "◁"
            color: "white"
            font.pixelSize: 30
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                cam.stopPreview()
                appWindowLoader.closeApp()
            }
        }
    }

    // ===== 右侧栏：快门（720..800）=====
    Item {
        id: rightBar
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 80

        Rectangle {
            id: shutter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            width: 60
            height: 60
            radius: width / 2
            color: cam.busy ? "#999999" : "white"
            border.color: "#333333"
            border.width: 2

            Behavior on color { ColorAnimation { duration: 120 } }

            MouseArea {
                anchors.fill: parent
                enabled: !cam.busy
                onPressed: parent.scale = 0.9
                onReleased: parent.scale = 1.0
                onClicked: {
                    flashRect.opacity = 0.9
                    flashAnim.start()
                    cam.capture()
                }
            }

            Behavior on scale { NumberAnimation { duration: 100 } }
        }

        // 保存/失败反馈
        Text {
            id: statusLabel
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: shutter.bottom
            anchors.topMargin: 18
            width: parent.width - 8
            horizontalAlignment: Text.AlignHCenter
            text: ""
            color: "white"
            font.pixelSize: 13
        }
    }

    Timer {
        id: statusTimer
        interval: 2000
        onTriggered: statusLabel.text = ""
    }

    // 拍照白闪（gst 停帧期间 Qt 可写帧缓冲）
    Rectangle {
        id: flashRect
        anchors.fill: parent
        color: "white"
        opacity: 0
        z: 40
    }

    NumberAnimation {
        id: flashAnim
        target: flashRect
        property: "opacity"
        to: 0
        duration: 250
    }
}
