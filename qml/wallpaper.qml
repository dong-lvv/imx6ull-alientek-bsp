import QtQuick 2.14
import QtQuick.Controls 2.14
import Qt.labs.folderlistmodel 2.14
import MyHardware 1.0

Rectangle {
    id: wallpaperApp
    anchors.fill: parent
    color: "#1A1A1A"

    // ==========================================
    // 顶部导航栏
    // ==========================================
    Rectangle {
        id: navBar
        anchors.top: parent.top
        width: parent.width
        height: 50
        color: "#CC000000"
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
            onClicked: appWindowLoader.closeApp()
        }

        Text {
            anchors.centerIn: parent
            text: "选择壁纸"
            color: "white"
            font.pixelSize: 16
            font.bold: true
        }

        // 恢复默认渐变背景
        Button {
            anchors.right: parent.right
            anchors.rightMargin: 15
            anchors.verticalCenter: parent.verticalCenter
            text: "默认"
            background: Item {}
            contentItem: Text {
                text: parent.text
                color: "#4facfe"
                font.pixelSize: 16
            }
            onClicked: Wallpaper.path = ""
        }
    }

    // ==========================================
    // 壁纸网格（读取相机照片目录）
    // ==========================================
    GridView {
        id: grid
        anchors.top: navBar.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        cellWidth: 160
        cellHeight: 160
        clip: true

        model: FolderListModel {
            folder: "file:///home/lv/photos"
            nameFilters: ["*.png", "*.jpg", "*.jpeg", "*.bmp"]
            showDirs: false
        }

        delegate: Item {
            width: grid.cellWidth
            height: grid.cellHeight

            Image {
                anchors.fill: parent
                anchors.margins: 2
                source: fileURL
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                sourceSize.width: 160
                sourceSize.height: 160

                // 当前已选中的壁纸加亮，其余略压暗
                opacity: (Wallpaper.path === fileURL) ? 1.0 : 0.75
            }

            // 选中标记
            Rectangle {
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.top: parent.top
                anchors.topMargin: 8
                width: 26
                height: 26
                radius: width / 2
                color: "#2ECC71"
                visible: Wallpaper.path === fileURL
                border.color: "white"
                border.width: 2

                Text {
                    anchors.centerIn: parent
                    text: "✓"
                    color: "white"
                    font.pixelSize: 16
                    font.bold: true
                }
            }

            MouseArea {
                anchors.fill: parent
                onPressed: parent.opacity = 0.6
                onReleased: parent.opacity = 1.0
                onClicked: {
                    // 先记录候选图，弹确认框
                    confirmDialog.imageUrl = fileURL
                    confirmDialog.open()
                }
            }
        }
    }

    // ==========================================
    // 设置壁纸确认弹窗
    // ==========================================
    Dialog {
        id: confirmDialog
        property string imageUrl: ""

        modal: true
        // 不设 x/y，模态 Dialog 自动居中于窗口
        width: 360
        height: 300

        background: Rectangle {
            radius: 16
            color: "#262626"
        }

        contentItem: Column {
            spacing: 14

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 200
                height: 130
                source: confirmDialog.imageUrl
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "将这张图片设置为壁纸？"
                color: "white"
                font.pixelSize: 17
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 20

                // 取消
                Rectangle {
                    width: 130
                    height: 44
                    radius: 22
                    color: "#444444"

                    Text {
                        anchors.centerIn: parent
                        text: "取消"
                        color: "white"
                        font.pixelSize: 16
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: confirmDialog.close()
                    }
                }

                // 确定
                Rectangle {
                    width: 130
                    height: 44
                    radius: 22
                    color: "#2ECC71"

                    Text {
                        anchors.centerIn: parent
                        text: "确定"
                        color: "white"
                        font.pixelSize: 16
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            Wallpaper.path = confirmDialog.imageUrl
                            confirmDialog.close()
                        }
                    }
                }
            }
        }
    }

    // 目录为空时的提示
    Text {
        anchors.centerIn: parent
        visible: grid.count === 0
        text: "照片目录为空\n先用相机拍几张照片吧"
        color: "#888888"
        font.pixelSize: 16
        horizontalAlignment: Text.AlignHCenter
    }
}
