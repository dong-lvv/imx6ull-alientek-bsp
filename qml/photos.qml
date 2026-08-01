import QtQuick 2.14
import QtQuick.Controls 2.14
import Qt.labs.folderlistmodel 2.14

Rectangle {
    id: photoApp
    anchors.fill: parent
    color: "#000000" // 相册通常用纯黑背景，能更好地凸显照片色彩

    // ==========================================
    // 1. 顶部导航栏 (半透明暗黑风格)
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
                color: "#FFFFFF"
                font.pixelSize: 16
            }
            onClicked: appWindowLoader.closeApp()
        }

        Text {
            anchors.centerIn: parent
            text: "图库"
            color: "white"
            font.pixelSize: 16
            font.bold: true
        }
    }

    // ==========================================
    // 2. 照片网格瀑布流
    // ==========================================
    GridView {
        id: photoGrid
        anchors.top: navBar.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        // 设置网格大小，800宽度放大概4-5张图比较合适
        cellWidth: 160
        cellHeight: 160
        clip: true

        model: FolderListModel {
            // 指向你的目标相册目录
            folder: "file:///home/lv/photos"
            // 核心功能 1：通过过滤器只加载常见的图片格式，屏蔽文本或隐藏文件
            nameFilters: ["*.png", "*.jpg", "*.jpeg", "*.bmp"]
            // 不显示子文件夹，只显示文件
            showDirs: false
        }

        delegate: Item {
            width: photoGrid.cellWidth
            height: photoGrid.cellHeight

            Image {
                // 留出 2px 的间距，让图片之间有缝隙，类似 iPhone 相册
                anchors.fill: parent
                anchors.margins: 1

                // 加载本地图片的 URL
                source: fileURL

                // 裁剪模式：保持比例填充，超出的部分裁掉，确保网格整齐
                fillMode: Image.PreserveAspectCrop

                // 【最关键的性能优化 1】：开启异步加载，滑动时绝对不卡主线程
                asynchronous: true

                // 【最关键的性能优化 2】：告诉底层解码器，不要把例如 4K 的原图解压进内存，
                // 直接在 C++ 底层缩放成 160x160 的缩略图再放进内存，能节省 95% 以上的 RAM！
                sourceSize.width: 160
                sourceSize.height: 160

                MouseArea {
                    anchors.fill: parent
                    onPressed: parent.opacity = 0.5
                    onReleased: parent.opacity = 1.0
                    onClicked: {
                        console.log("查看大图: " + fileURL)
                        // 这里可以触发大图预览逻辑
                    }
                }
            }
        }
    }
}
