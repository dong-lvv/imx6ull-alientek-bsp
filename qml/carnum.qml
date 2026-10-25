import QtQuick 2.14
import QtQuick.Controls 2.14
import MyHardware 1.0

Rectangle {
    id: carnumApp
    anchors.fill: parent
    color: "#000000"

    CameraBackend {
        id: cam
        device: "/dev/video1"
        saveFolder: "/home/lv/photos"
        // 640x400 预览：左右各留 80px、底部留 40px 给 Qt 控件（fbdevsink 不刷新这些区域）
        previewWidth: 640
        previewHeight: 400

        onSaved: {
            statusLabel.text = "✓ 已拍照"
            statusTimer.restart()
            // TODO: 后续在这里调用识别后端 recognize(path)
        }
        onFailed: {
            statusLabel.text = "✗ 失败"
            statusTimer.restart()
        }
    }

    // 进入即开始全屏预览（640x400 居中，x=80..720, y=40..440）
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

    // ===== 右侧栏：拍照识别按钮（720..800）=====
    Item {
        id: rightBar
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 80

        Rectangle {
            id: shutterBtn
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            width: 56
            height: 150
            radius: 28
            color: cam.busy ? "#999999" : "#FFFFFF"
            border.color: "#333333"
            border.width: 2

            Behavior on color { ColorAnimation { duration: 120 } }
            Behavior on scale { NumberAnimation { duration: 100 } }

            Text {
                anchors.centerIn: parent
                rotation: -90
                text: "拍照识别"
                color: "#222222"
                font.pixelSize: 20
                font.bold: true
            }

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
        }

        // 拍照成功/失败反馈
        Text {
            id: statusLabel
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: shutterBtn.bottom
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

    // ===== 底部：车牌号显示区（y=440..480，视频不刷新此区域）=====
    Rectangle {
        id: resultBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 40
        color: "#111111"

        Text {
            id: plateLabel
            anchors.centerIn: parent
            text: "车牌号：--"
            color: "#FFD700"
            font.pixelSize: 24
            font.bold: true
        }
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
