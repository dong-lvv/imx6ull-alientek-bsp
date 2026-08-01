import QtQuick 2.14
import QtQuick.Controls 2.14
import Qt.labs.folderlistmodel 2.14

Rectangle {
    id: videoApp
    anchors.fill: parent
    color: "#1c1c1e"

    // ==========================================
    // 1. 顶部导航/控制栏
    // ==========================================
    Rectangle {
        id: navBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 50
        color: "#2c2c2e"
        z: 2

        Button {
            anchors.left: parent.left
            anchors.leftMargin: 15
            anchors.verticalCenter: parent.verticalCenter
            text: "◁ 返回桌面"
            background: Rectangle { color: "transparent" }
            contentItem: Text { text: parent.text; color: "#0a84ff"; font.pixelSize: 16 }
            onClicked: {
                appWindowLoader.closeApp()
            }
        }

        Text {
            anchors.centerIn: parent
            text: "本地视频 (MP4)"
            color: "white"
            font.pixelSize: 18
            font.bold: true
        }
    }

    // ==========================================
    // 2. 视频文件扫描与列表区域
    // ==========================================
    FolderListModel {
        id: folderModel
        folder: "file:///home/lv/videos"
        nameFilters: ["*.mp4", "*.MP4"]
        showDirs: false
    }

    ListView {
        id: videoListView
        anchors.top: navBar.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 20
        spacing: 10
        model: folderModel
        clip: true

        delegate: Rectangle {
            width: ListView.view.width
            height: 70
            color: "#3a3a3c"
            radius: 12

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.verticalCenter: parent.verticalCenter
                text: "🎬 " + fileName
                color: "white"
                font.pixelSize: 16
            }

            MouseArea {
                anchors.fill: parent
                onPressed: parent.opacity = 0.7
                onReleased: parent.opacity = 1.0
                onClicked: {
                    // ==========================================
                    // ⚠️ 这里预留给你未来接入独立播放器 QML 的接口
                    // ==========================================
                    console.log("准备把这个文件传给独立播放器: " + fileUrl)

                    // 未来你可以在这里写类似这样的逻辑：
                    // playerLoader.source = "qrc:/qml/player.qml"
                    // playerLoader.item.videoUrl = fileUrl
                }
            }
        }

        // 没找到视频时的提示
        Text {
            anchors.centerIn: parent
            text: "未找到 MP4 视频\n请确保视频文件位于 /home/lv/videos 目录"
            color: "gray"
            font.pixelSize: 16
            horizontalAlignment: Text.AlignHCenter
            visible: folderModel.count === 0
        }
    }
}
