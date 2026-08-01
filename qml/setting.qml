import QtQuick 2.14
import QtQuick.Controls 2.14

Rectangle {
    id: settingApp
    anchors.fill: parent
    color: "#F2F2F7" // iPadOS 经典浅灰背景

    // ==========================================
    // 1. 顶部全局导航栏 (虽然 iPadOS 设置通常没有全局返回，但为了适配我们的 OS 框架需要保留)
    // ==========================================
    Rectangle {
        id: navBar
        anchors.top: parent.top
        width: parent.width
        height: 50
        color: "#F2F2F7"
        z: 10

        // 底部极细分割线
        Rectangle {
            width: parent.width; height: 1; color: "#D1D1D6"
            anchors.bottom: parent.bottom
        }

        Button {
            anchors.left: parent.left
            anchors.leftMargin: 15
            anchors.verticalCenter: parent.verticalCenter
            text: "◁ 返回主界面"
            background: Item {}
            contentItem: Text {
                text: parent.text
                color: "#007AFF"
                font.pixelSize: 16
            }
            onClicked: appWindowLoader.closeApp()
        }
    }

    // ==========================================
    // 2. 左右分栏布局
    // ==========================================
    Row {
        anchors.top: navBar.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        // ------------------------------------------
        // 左侧：设置项目标列表栏 (固定宽度)
        // ------------------------------------------
        Item {
            width: 280
            height: parent.height

            ListView {
                id: settingsList
                anchors.fill: parent
                // 上下留出空白边距
                anchors.topMargin: 15
                anchors.bottomMargin: 15
                anchors.leftMargin: 15
                anchors.rightMargin: 15
                clip: true

                // 数据模型：通过 isFirst 和 isLast 标识来控制分组和圆角渲染
                model: ListModel {
                    // 第 1 组：账户
                    ListElement { title: "Apple ID、iCloud"; iconText: "👤"; bgColor: "#8E8E93"; isFirst: true; isLast: true }

                    // 第 2 组：网络
                    ListElement { title: "无线局域网"; iconText: "📶"; bgColor: "#007AFF"; isFirst: true; isLast: false }
                    ListElement { title: "蓝牙"; iconText: "B"; bgColor: "#007AFF"; isFirst: false; isLast: false }
                    ListElement { title: "蜂窝网络"; iconText: "🌐"; bgColor: "#34C759"; isFirst: false; isLast: true }

                    // 第 3 组：通知与声音
                    ListElement { title: "通知"; iconText: "🔔"; bgColor: "#FF3B30"; isFirst: true; isLast: false }
                    ListElement { title: "声音"; iconText: "🔊"; bgColor: "#FF3B30"; isFirst: false; isLast: false }
                    ListElement { title: "专注模式"; iconText: "🌙"; bgColor: "#5856D6"; isFirst: false; isLast: true }

                    // 第 4 组：通用与控制
                    ListElement { title: "通用"; iconText: "⚙"; bgColor: "#8E8E93"; isFirst: true; isLast: false }
                    ListElement { title: "控制中心"; iconText: "🎛"; bgColor: "#8E8E93"; isFirst: false; isLast: false }
                    ListElement { title: "显示与亮度"; iconText: "☀"; bgColor: "#007AFF"; isFirst: false; isLast: true }
                }

                delegate: Item {
                    width: settingsList.width
                    // 【核心逻辑】：如果是一个组的第一个项，增加 20px 的顶部留白产生分组效果
                    height: isFirst ? 65 : 45

                    // 承载单个项的背景色块
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 45
                        color: "white"
                        // 基础圆角
                        radius: 10

                        // 【性能优化】：软渲染拼图去圆角法
                        // 只有处于开头且非结尾时，底部才需要变成直角
                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width; height: 10
                            color: "white"
                            visible: isFirst && !isLast
                        }
                        // 只有处于结尾且非开头时，顶部才需要变成直角
                        Rectangle {
                            anchors.top: parent.top
                            width: parent.width; height: 10
                            color: "white"
                            visible: isLast && !isFirst
                        }
                        // 如果在中间，干脆用全直角的方块覆盖
                        Rectangle {
                            anchors.fill: parent
                            color: "white"
                            visible: !isFirst && !isLast
                        }

                        // 内容排版
                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 15
                            anchors.rightMargin: 15
                            spacing: 12
                            anchors.verticalCenter: parent.verticalCenter

                            // 模拟 iOS 设置项左侧的彩色方块图标
                            Rectangle {
                                width: 28; height: 28
                                radius: 6
                                color: model.bgColor
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    anchors.centerIn: parent
                                    text: model.iconText // 如果有真实图片这里换成 Image 即可
                                    color: "white"
                                    font.pixelSize: 14
                                }
                            }

                            // 标题
                            Text {
                                text: model.title
                                font.pixelSize: 16
                                anchors.verticalCenter: parent.verticalCenter
                                color: "black"
                            }
                        }

                        // 列表项右侧的箭头指示器 '>'
                        Text {
                            anchors.right: parent.right
                            anchors.rightMargin: 15
                            anchors.verticalCenter: parent.verticalCenter
                            text: "〉"
                            color: "#C7C7CC"
                            font.pixelSize: 14
                        }

                        // 分割细线：处于中间的列表项需要一条不贯穿左侧图标区的分割线
                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 55 // 避开左侧的彩色方块
                            height: 1
                            color: "#E5E5EA"
                            visible: !isLast
                        }

                        // 交互反馈
                        MouseArea {
                            anchors.fill: parent
                            onPressed: parent.opacity = 0.7
                            onReleased: parent.opacity = 1.0
                            onClicked: {
                                // 点击时更新右侧的标题显示
                                detailTitle.text = model.title
                                detailText.text = "这里是【" + model.title + "】的详细设置内容。"
                            }
                        }
                    }
                }
            }
        }

        // ------------------------------------------
        // 中间：深色分割线 (模拟分栏阴影)
        // ------------------------------------------
        Rectangle {
            width: 1
            height: parent.height
            color: "#D1D1D6"
        }

        // ------------------------------------------
        // 右侧：详细内容展示区 (占满剩余空间)
        // ------------------------------------------
        Rectangle {
            width: parent.width - 280 - 1
            height: parent.height
            color: "#F2F2F7"

            Column {
                anchors.centerIn: parent
                spacing: 20

                // 大号图标占位
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "⚙"
                    font.pixelSize: 80
                    color: "#C7C7CC"
                }

                // 动态更新的标题
                Text {
                    id: detailTitle
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "设置"
                    font.pixelSize: 28
                    font.bold: true
                    color: "black"
                }

                // 动态更新的描述文本
                Text {
                    id: detailText
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "请在左侧选择要调整的设置项"
                    font.pixelSize: 16
                    color: "#8E8E93"
                }
            }
        }
    }
}
