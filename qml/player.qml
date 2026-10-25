import QtQuick 2.14
import QtQuick.Controls 2.14
import MyOS.Backend 1.0  // 1. 引入刚才在 main.cpp 中注册的 C++ 后端

Rectangle {
    id: playerUI
    anchors.fill: parent
    // 2. 这里的背景必须是透明的（transparent），否则黑色的背景会挡住底层直接刷在屏幕(fb0)上的视频！
    color: "transparent"

    // 3. 实例化 C++ 后端类，给它取个名字叫 backend
    VideoBackend {
        id: backend
    }

    // 接收从视频列表传过来的视频路径
    property string videoUrl: ""
    // 播放状态控制
    property bool isPlaying: true
    // 控制面板是否显示
    property bool controlsVisible: true

    // 监听：当页面加载并接收到视频路径时，真正通知 C++ 开始播放
    onVideoUrlChanged: {
        if (videoUrl !== "") {
            console.log("▶️ [UI指令] 真正调用 C++ 开始播放视频: " + videoUrl)
            backend.play(videoUrl)  // 调用 C++ 的 play 函数
        }
    }

    // 页面销毁时（退出播放器），真正通知 C++ 停止播放
    Component.onDestruction: {
        console.log("⏹️ [UI指令] 退出播放器，真正调用 C++ 杀死底层进程")
        backend.stop()  // 调用 C++ 的 stop 函数
    }

    // 自动隐藏控制条的定时器 (3秒无操作自动隐藏)
    Timer {
        id: hideTimer
        interval: 3000
        running: controlsVisible
        repeat: false
        onTriggered: controlsVisible = false
    }

    // 点击屏幕任意位置：显示/隐藏 控制台，并重置定时器
    MouseArea {
        anchors.fill: parent
        onClicked: {
            controlsVisible = !controlsVisible
            if (controlsVisible) {
                hideTimer.restart()
            }
        }
    }

    // ==========================================
    // 顶部控制栏 (返回按钮 + 视频名)
    // ==========================================
    Rectangle {
        id: topBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 60
        // 毛玻璃半透明效果
        color: Qt.rgba(0.1, 0.1, 0.1, 0.8)
        opacity: controlsVisible ? 1.0 : 0.0

        Button {
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            text: "◁ 返回"
            background: Rectangle { color: "transparent" }
            contentItem: Text { text: parent.text; color: "white"; font.pixelSize: 18 }
            onClicked: {
                // 退回视频列表
                appWindowLoader.source = "qrc:/qml/video.qml"
            }
        }

        Text {
            anchors.centerIn: parent
            text: videoUrl.substring(videoUrl.lastIndexOf("/") + 1) // 提取文件名
            color: "white"
            font.pixelSize: 16
        }
    }

    // ==========================================
    // 底部控制栏 (播放/暂停 按钮)
    // ==========================================
    Rectangle {
        id: bottomBar
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 80
        color: Qt.rgba(0.1, 0.1, 0.1, 0.8)
        opacity: controlsVisible ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 300 } }

        // 居中播放/暂停按钮
        Rectangle {
            width: 50
            height: 50
            radius: 25
            color: "#3a3a3c"
            anchors.centerIn: parent

            Text {
                anchors.centerIn: parent
                // 用简单的字符图标代替图片
                text: isPlaying ? "⏸" : "▶"
                color: "white"
                font.pixelSize: 24
            }

            MouseArea {
                anchors.fill: parent
                onPressed: parent.color = "#5a5a5c"
                onReleased: parent.color = "#3a3a3c"
                onClicked: {
                    isPlaying = !isPlaying
                    hideTimer.restart()
                    if (isPlaying) {
                        console.log("▶️ [UI指令] 调用 C++ 恢复播放")
                        backend.resume() // 调用 C++ 的 resume 函数
                    } else {
                        console.log("⏸ [UI指令] 调用 C++ 暂停播放")
                        backend.pause() // 调用 C++ 的 pause 函数
                    }
                }
            }
        }
    }
}
