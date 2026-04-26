import QtQuick 6.8
import QtQuick.Controls 6.8
import Rx8_HeadUnit

Item {
    id: root

    property string text: ""
    property url iconSource: ""
    property bool checked: false
    property bool checkable: true

    property color normalColor: "#2b2b2b"
    property color checkedColor: "#ffffff"
    property color pressedColor: "#3a3a3a"
    property color borderColor: "#ffffff"
    property color textColor: checked ? "#111111" : "#ffffff"
    property color disabledColor: "#555555"

    signal clicked()

    implicitWidth: 150
    implicitHeight: 76

    scale: mouseArea.pressed ? 0.96 : 1.0
    opacity: enabled ? 1.0 : 0.45

    Behavior on scale {
        NumberAnimation { duration: 90 }
    }

    Rectangle {
        anchors.fill: parent
        radius: 18
        color: !root.enabled ? root.disabledColor
              : mouseArea.pressed ? root.pressedColor
              : root.checked ? root.checkedColor
              : root.normalColor

        border.width: root.checked ? 0 : 1
        border.color: root.borderColor
    }

    Column {
        anchors.centerIn: parent
        spacing: 6

        Image {
            id: icon
            width: 26
            height: 26
            anchors.horizontalCenter: parent.horizontalCenter
            source: root.iconSource
            visible: root.iconSource !== ""
            fillMode: Image.PreserveAspectFit
        }

        Text {
            text: root.text
            color: root.textColor
            font.family: Constants.font.family
            font.pixelSize: 18
            font.bold: root.checked
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: root.enabled

        onClicked: {
            if (root.checkable)
                root.checked = !root.checked

            root.clicked()
        }
    }
}
