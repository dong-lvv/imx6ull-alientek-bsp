import QtQuick 2.14
import QtQuick.Controls 2.14
import Qt.labs.folderlistmodel 2.14

Rectangle {
    anchors.fill: parent
    color: "#FFFFFF"

    // 定义一个根目录属性，方便全局统一管理
    property string rootDir: "file:///home/lv"

    // ==========================================
    // 1. 顶部导航栏
    // ==========================================
    Rectangle {
        id: navBar
        anchors.top: parent.top
        width: parent.width
        height: 50
        color: "#F6F6F6"
        z: 10

        Rectangle {
            width: parent.width; height: 1; color: "#E0E0E0"
            anchors.bottom: parent.bottom
        }

        Row {
            anchors.left: parent.left
            anchors.leftMargin: 15
            anchors.verticalCenter: parent.verticalCenter
            spacing: 20

            Button {
                text: "🔴 关闭"
                background: Item {}
                contentItem: Text {
                    text: parent.text
                    color: "#FF5F56"
                    font.pixelSize: 15
                    font.bold: true
                }
                onClicked: appWindowLoader.closeApp()
            }

            // 【核心修复 1】：使用自定义函数剔除末尾斜杠，保证字符串比对绝对准确
            Button {
                text: "◁ 返回上级"
                visible: stripSlash(fileModel.folder) !== stripSlash(rootDir)
                background: Item {}
                contentItem: Text {
                    text: parent.text
                    color: "#007AFF"
                    font.pixelSize: 15
                }
                onClicked: {
                    fileModel.folder = fileModel.parentFolder
                }
            }
        }

        Text {
            anchors.centerIn: parent
            text: "文件 - " + fileModel.folder.toString().replace("file://", "")
            font.pixelSize: 15
            font.bold: true
            color: "#333333"
        }
    }

    // ==========================================
    // 2. 网格文件展示区
    // ==========================================
    GridView {
        id: fileGrid
        anchors.top: navBar.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 20
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        clip: true
        cellWidth: 100
        cellHeight: 120

        model: FolderListModel {
            id: fileModel
            folder: rootDir // 绑定顶部定义的根目录
            showDirsFirst: true
            showDotAndDotDot: false
        }

        delegate: Item {
            width: fileGrid.cellWidth
            height: fileGrid.cellHeight

            Column {
                anchors.centerIn: parent
                spacing: 8
                width: parent.width - 10

                Image {
                    width: 56
                    height: 56
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: fileIsDir ? "qrc:/icons/dir.png" : "qrc:/icons/file.png"
                    fillMode: Image.PreserveAspectFit
                }

                Text {
                    width: parent.width
                    text: fileName
                    font.pixelSize: 13
                    color: "#333333"
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                }
            }

            MouseArea {
                anchors.fill: parent
                onPressed: parent.opacity = 0.5
                onReleased: parent.opacity = 1.0
                onClicked: {
                    if (fileIsDir) {
                        // 【核心修复 2】：必须使用 fileURL (自带 file:// 前缀)，不能用 filePath
                        console.log("进入文件夹: " + fileURL)
                        fileModel.folder = fileURL
                    } else {
                        console.log("尝试打开文件: " + fileName)
                    }
                }
            }
        }
    }

    // 辅助函数：去掉 URL 字符串末尾可能存在的斜杠
    function stripSlash(pathStr) {
        var str = pathStr.toString()
        if (str.endsWith("/")) {
            return str.slice(0, -1)
        }
        return str
    }
}
