import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.14

Window {
    visible: true
    width: 800
    height: 480
    title: qsTr("iPadOS Clone")

    // ==========================================
    // 统一的 App 启动路由函数 (完全使用纯英文 appId 判断)
    // ==========================================
    function openApp(appId) {
        console.log("正在启动 App ID: " + appId)

        if (appId === "file") {
            appWindowLoader.source = "qrc:/qml/resources.qml"
            appWindowLoader.active = true
        }
        else if (appId === "light") {
            appWindowLoader.source = "qrc:/qml/light.qml"
            appWindowLoader.active = true
        }
        else if (appId === "calculator") {
            appWindowLoader.source = "qrc:/qml/calculator.qml"
            appWindowLoader.active = true
        }
        else if (appId === "photos") {
             appWindowLoader.source = "qrc:/qml/photos.qml"
             appWindowLoader.active = true
         }
        else if (appId === "setting") {
              appWindowLoader.source = "qrc:/qml/setting.qml"
              appWindowLoader.active = true
         }
        else if (appId === "video") {
              appWindowLoader.source = "qrc:/qml/video.qml"
              appWindowLoader.active = true
         }
    }

    // ==========================================
    // 0. 背景层
    // ==========================================
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#4facfe" }
            GradientStop { position: 1.0; color: "#00f2fe" }
        }
    }

    // ==========================================
    // 1. 顶部：通知/状态栏 (Status Bar)
    // ==========================================
    Item {
        id: statusBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 30
        z: 2

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            text: "9:41 AM  周三 10月18日"
            color: "white"
            font.pixelSize: 14
            font.bold: true
        }

        Row {
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            spacing: 15
            Text { text: "100%"; color: "white"; font.pixelSize: 14; font.bold: true }
            Text { text: "🔋"; color: "white"; font.pixelSize: 14 }
            Text { text: "📶"; color: "white"; font.pixelSize: 14 }
        }
    }

    // ==========================================
    // 2. 底部：Dock 停靠栏
    // ==========================================
    Rectangle {
        id: dockBar
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 15
        anchors.horizontalCenter: parent.horizontalCenter
        height: 75
        width: dockRow.width + 40
        radius: 25
        color: "#40FFFFFF"
        z: 2

        Row {
            id: dockRow
            anchors.centerIn: parent
            spacing: 20

            Repeater {
                model: ListModel {
                    // 【核心修改】：在这里为每个 App 添加纯小写英文的 appId
                    ListElement { name: "设置"; appId: "setting"; iconSource: "qrc:/icons/setting.png" }
                    ListElement { name: "图库"; appId: "photos"; iconSource: "qrc:/icons/photos.png" }
                    ListElement { name: "音乐"; appId: "music"; iconSource: "qrc:/icons/music.png" }
                    ListElement { name: "文件"; appId: "file"; iconSource: "qrc:/icons/resources.png" }
                }
                delegate: dockIconDelegate
            }
        }
    }

    // ==========================================
    // 3. 中间：多页面滑动区 (Workspace)
    // ==========================================
    SwipeView {
        id: workspace
        anchors.top: statusBar.bottom
        anchors.bottom: dockBar.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottomMargin: 20
        clip: true

        // 第一页
        Item {
            GridView {
                anchors.fill: parent
                anchors.margins: 40
                cellWidth: 100
                cellHeight: 110
                interactive: false
                model: ListModel {
                    // 【核心修改】：在这里为每个 App 添加纯小写英文的 appId
                    ListElement { name: "手电筒"; appId: "light"; iconSource: "qrc:/icons/light.png" }
                    ListElement { name: "天气"; appId: "weather"; iconSource: "qrc:/icons/weather.png" }
                    ListElement { name: "音乐"; appId: "music"; iconSource: "qrc:/icons/music.png" }
                    ListElement { name: "计算器"; appId: "calculator"; iconSource: "qrc:/icons/jisuanqi.png" }
                    ListElement { name: "视频"; appId: "video"; iconSource: "qrc:/icons/video.png" }
                    ListElement { name: "设置"; appId: "setting"; iconSource: "qrc:/icons/setting.png" }
                    ListElement { name: "哔哩哔哩"; appId: "bilibili"; iconSource: "qrc:/icons/bilibili.png" }
                    ListElement { name: "游戏"; appId: "games"; iconSource: "qrc:/icons/games.png" }
                }
                delegate: appIconDelegate
            }
        }

        // 第二页
        Item {
            GridView {
                anchors.fill: parent
                anchors.margins: 40
                cellWidth: 100
                cellHeight: 110
                interactive: false
                model: ListModel {
                    ListElement { name: "游戏"; appId: "games"; iconSource: "qrc:/icons/games.png" }
                    ListElement { name: "视频"; appId: "video"; iconSource: "qrc:/icons/video.png" }
                }
                delegate: appIconDelegate
            }
        }
    }

    PageIndicator {
        count: workspace.count
        currentIndex: workspace.currentIndex
        anchors.bottom: workspace.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        delegate: Rectangle {
            implicitWidth: 8
            implicitHeight: 8
            radius: width / 2
            color: index === workspace.currentIndex ? "white" : "#66FFFFFF"
        }
    }

    // ==========================================
    // 通用组件：桌面 App 图标 Delegate
    // ==========================================
    Component {
        id: appIconDelegate
        Item {
            width: 80
            height: 90

            Column {
                anchors.centerIn: parent
                spacing: 8

                Image {
                    width: 60
                    height: 60
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: model.iconSource
                    fillMode: Image.PreserveAspectFit

                    MouseArea {
                        anchors.fill: parent
                        onPressed: parent.opacity = 0.6
                        onReleased: parent.opacity = 1.0
                        onClicked: {
                            // 【核心修改】：把 model.name 换成 model.appId
                            openApp(model.appId)
                        }
                    }
                }

                Text {
                    text: model.name
                    color: "white"
                    font.pixelSize: 12
                    anchors.horizontalCenter: parent.horizontalCenter
                    style: Text.Outline
                    styleColor: "#40000000"
                }
            }
        }
    }

    // ==========================================
    // 通用组件：Dock App 图标 Delegate
    // ==========================================
    Component {
        id: dockIconDelegate
        Item {
            width: 60
            height: 60

            Image {
                anchors.fill: parent
                source: model.iconSource
                fillMode: Image.PreserveAspectFit

                MouseArea {
                    anchors.fill: parent
                    onPressed: parent.opacity = 0.6
                    onReleased: parent.opacity = 1.0
                    onClicked: {
                        // 【核心修改】：把 model.name 换成 model.appId
                        openApp(model.appId)
                    }
                }
            }
        }
    }

    // ==========================================
    // 4. 应用运行层 (App Window)
    // ==========================================
        Loader {
            id: appWindowLoader
            anchors.fill: parent
            z: 100
            active: false

            // 核心抓虫代码：千万不要删！
            onStatusChanged: {
                if (status === Loader.Error) {
                    console.error("\n❌❌❌ Loader 致命报错 ❌❌❌")
                    console.error("加载文件: " + source)
                    // 这行虽然 QML 原生不直接提供 detailed error 字符串，
                    // 但触发 Error 状态时，Qt Creator 底部的控制台一定会自动打印红色的详细原因！
                } else if (status === Loader.Ready) {
                    console.log("✅ 成功加载页面: " + source)
                }
            }

            function closeApp() {
                active = false
                source = ""
            }
        }
}
