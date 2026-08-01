import QtQuick 2.14
import QtQuick.Controls 2.14
import Qt.labs.folderlistmodel 2.14 // 引入文件夹列表模型

Rectangle {
    anchors.fill: parent
    color: "#F2F2F7" // 类似 iOS 的浅灰色背景

    // 1. 顶部导航栏 (包含返回按钮)
    Rectangle {
        id: navBar
        anchors.top: parent.top
        width: parent.width
        height: 50
        color: "white"
        z: 10

        // 简单的底部阴影分割线
        Rectangle {
            width: parent.width; height: 1; color: "#E5E5EA"
            anchors.bottom: parent.bottom
        }

        // 返回桌面的按钮
        Button {
            anchors.left: parent.left
            anchors.leftMargin: 15
            anchors.verticalCenter: parent.verticalCenter
            text: "◁ 返回"
            // 设置按钮透明样式
            background: Item {}
            contentItem: Text {
                text: parent.text
                color: "#007AFF" // iOS 经典蓝色
                font.pixelSize: 16
            }
            onClicked: {
                // 调用 main.qml 中 Loader 的自定义函数关闭自己
                appWindowLoader.closeApp()
            }
        }

        Text {
            anchors.centerIn: parent
            text: "文件 - /home/lv"
            font.pixelSize: 16
            font.bold: true
        }
    }

    // 2. 文件列表展示区
    ListView {
        id: fileList
        anchors.top: navBar.bottom
        anchors.bottom: parent.bottom
        width: parent.width
        clip: true

        // 定义数据源：指向 /home/lv 目录
        model: FolderListModel {
            // 注意：Linux 本地绝对路径前面要加 file://
            folder: "file:///home/lv"
            showDirsFirst: true // 文件夹排在前面
            showDotAndDotDot: false // 隐藏 . 和 ..
        }

        // 定义每一行长什么样
        delegate: Item {
            width: fileList.width
            height: 60

            // 底部细线分割
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 60
                height: 1
                color: "#E5E5EA"
            }

            Row {
                anchors.fill: parent
                anchors.leftMargin: 15
                spacing: 15
                anchors.verticalCenter: parent.verticalCenter

                // 文件/文件夹图标 (简单的色块区分)
                Rectangle {
                    width: 40
                    height: 40
                    radius: 8
                    anchors.verticalCenter: parent.verticalCenter
                    color: fileIsDir ? "#8E8E93" : "#007AFF"

                    Text {
                        anchors.centerIn: parent
                        text: fileIsDir ? "📁" : "📄"
                        font.pixelSize: 20
                    }
                }

                // 文件名
                Text {
                    text: fileName
                    font.pixelSize: 16
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // 点击动画反馈
            MouseArea {
                anchors.fill: parent
                onPressed: parent.opacity = 0.5
                onReleased: parent.opacity = 1.0
                onClicked: {
                    if (fileIsDir) {
                        console.log("进入文件夹: " + filePath)
                        // 进阶功能：如果是文件夹，可以修改 model.folder = filePath 进入下一级
                    } else {
                        console.log("尝试打开文件: " + fileName)
                    }
                }
            }
        }
    }
}
