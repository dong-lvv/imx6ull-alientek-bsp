import QtQuick 2.14
import QtQuick.Controls 2.14

Rectangle {
    id: calcApp
    anchors.fill: parent
    color: "#000000"

    // ==========================================
    // 1. 顶部导航栏
    // ==========================================
    Item {
        id: navBar
        anchors.top: parent.top
        width: parent.width
        height: 50
        z: 10

        Button {
            anchors.left: parent.left
            anchors.leftMargin: 15
            anchors.verticalCenter: parent.verticalCenter
            text: "◁ 返回"
            background: Item {}
            contentItem: Text {
                text: parent.text
                color: "#FF9F0A"
                font.pixelSize: 16
            }
            onClicked: {
                appWindowLoader.closeApp()
            }
        }
    }

    // ==========================================
    // 2. 计算器核心运算逻辑
    // ==========================================
    property string currentInput: "0"
    property string previousInput: ""
    property string currentOperator: ""
    property bool waitForNewInput: false

    function handleInput(key) {
        if (key >= "0" && key <= "9") {
            if (currentInput === "0" || waitForNewInput) {
                currentInput = key
                waitForNewInput = false
            } else {
                if (currentInput.length < 9) {
                    currentInput += key
                }
            }
        } else if (key === "AC") {
            currentInput = "0"
            previousInput = ""
            currentOperator = ""
        } else if (key === "+/-") {
            if (currentInput !== "0" && currentInput !== "错误") {
                if (currentInput.charAt(0) === "-") {
                    currentInput = currentInput.substring(1)
                } else {
                    currentInput = "-" + currentInput
                }
            }
        } else if (key === "%") {
            if (currentInput !== "错误") {
                currentInput = (parseFloat(currentInput) / 100).toString()
            }
        } else if (key === ".") {
            if (currentInput.indexOf(".") === -1) {
                currentInput += "."
                waitForNewInput = false
            }
        } else if (key === "=") {
            calculate()
            currentOperator = ""
            waitForNewInput = true
        } else {
            if (currentOperator !== "" && !waitForNewInput) {
                calculate()
            }
            previousInput = currentInput
            currentOperator = key
            waitForNewInput = true
        }
    }

    function calculate() {
        var prev = parseFloat(previousInput)
        var curr = parseFloat(currentInput)
        var res = 0

        if (isNaN(prev) || isNaN(curr)) return

        if (currentOperator === "+") res = prev + curr
        else if (currentOperator === "-") res = prev - curr
        else if (currentOperator === "x") res = prev * curr
        else if (currentOperator === "÷") {
            if (curr === 0) {
                currentInput = "错误"
                return
            }
            res = prev / curr
        } else {
            return
        }

        currentInput = parseFloat(res.toFixed(6)).toString()
    }

    // ==========================================
    // 3. 主体 UI 布局 (针对 480 高度进行缩放优化)
    // ==========================================
    Item {
        // 总宽度: 4个60px的按钮 + 3个10px的间距 = 270
        width: 270
        // 总高度: 60px显示屏 + 15px间距 + 340px键盘 = 415
        height: 415
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 15

        // 显示屏区域
        Text {
            id: display
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 60 // 高度缩减
            text: currentInput
            color: "white"
            font.pixelSize: 50 // 字号适当缩小
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignBottom
            fontSizeMode: Text.Fit
            minimumPixelSize: 25
        }

        // 键盘区域
        Column {
            anchors.top: display.bottom
            anchors.topMargin: 15 // 间距缩减
            spacing: 10

            Row {
                spacing: 10
                CalcButton { text: "AC"; bgColor: "#A5A5A5"; textColor: "black" }
                CalcButton { text: "+/-"; bgColor: "#A5A5A5"; textColor: "black" }
                CalcButton { text: "%"; bgColor: "#A5A5A5"; textColor: "black" }
                CalcButton { text: "÷"; bgColor: "#FF9F0A"; textColor: "white"; isOp: true }
            }
            Row {
                spacing: 10
                CalcButton { text: "7" }
                CalcButton { text: "8" }
                CalcButton { text: "9" }
                CalcButton { text: "x"; bgColor: "#FF9F0A"; textColor: "white"; isOp: true }
            }
            Row {
                spacing: 10
                CalcButton { text: "4" }
                CalcButton { text: "5" }
                CalcButton { text: "6" }
                CalcButton { text: "-"; bgColor: "#FF9F0A"; textColor: "white"; isOp: true }
            }
            Row {
                spacing: 10
                CalcButton { text: "1" }
                CalcButton { text: "2" }
                CalcButton { text: "3" }
                CalcButton { text: "+"; bgColor: "#FF9F0A"; textColor: "white"; isOp: true }
            }
            Row {
                spacing: 10
                // 左下角特殊的宽按钮 "0"
                Rectangle {
                    width: 130 // 刚好占两个60的按钮加上10的间距
                    height: 60
                    radius: 30
                    color: btnMouse.pressed ? "#737373" : "#333333"
                    Text {
                        text: "0"
                        anchors.left: parent.left
                        anchors.leftMargin: 24
                        anchors.verticalCenter: parent.verticalCenter
                        color: "white"
                        font.pixelSize: 28
                    }
                    MouseArea {
                        id: btnMouse
                        anchors.fill: parent
                        onClicked: handleInput("0")
                    }
                }
                CalcButton { text: "." }
                CalcButton { text: "="; bgColor: "#FF9F0A"; textColor: "white" }
            }
        }
    }

    // ==========================================
    // 4. 内部复用组件
    // ==========================================
    component CalcButton: Rectangle {
        property string text: ""
        property color bgColor: "#333333"
        property color textColor: "white"
        property bool isOp: false

        // 按钮尺寸整体缩小至 60px
        width: 60
        height: 60
        radius: 30

        color: (isOp && currentOperator === text && waitForNewInput)
               ? "white"
               : (mouse.pressed ? Qt.darker(bgColor, 1.5) : bgColor)

        Text {
            anchors.centerIn: parent
            text: parent.text
            color: (isOp && currentOperator === parent.text && waitForNewInput)
                   ? "#FF9F0A"
                   : parent.textColor
            font.pixelSize: 26 // 字号跟随缩小
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            onClicked: handleInput(parent.text)
        }
    }
}
