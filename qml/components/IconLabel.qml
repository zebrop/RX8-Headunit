import QtQuick 6.8
import Rx8_HeadUnit

Item {
    id: root

    property string text: ""
    property url iconSource: ""
    property int iconSize: 24
    property int textSize: Theme.bodyTextSize
    property color textColor: Theme.textPrimary
    property bool iconVisible: iconSource !== ""
    property int spacing: -10

    implicitWidth: Math.max(icon.implicitWidth, label.implicitWidth)
    implicitHeight: icon.height + root.spacing + label.implicitHeight

    Column {
        anchors.centerIn: parent
        spacing: root.spacing

        Image {
            id: icon
            width: root.iconSize
            height: root.iconSize
            anchors.horizontalCenter: parent.horizontalCenter
            fillMode: Image.PreserveAspectFit
            source: root.iconSource
            visible: root.iconVisible
        }

        Text {
            id: label
            text: root.text
            color: root.textColor
            font.pixelSize: root.textSize
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
