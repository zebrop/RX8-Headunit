import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Effects
import Rx8_HeadUnit

Item {
    id: root

    property string buttonText: ""
    property url imageSource: ""
    property color glowColor: Theme.accentColor
    property bool selected: false
    readonly property bool highlighted: selected || hovered
    property bool hovered: false
    property bool pressed: false

    signal clicked()

    width: 575
    height: 280

    Rectangle {
        id: glowSource
        anchors.fill: buttonFrame
        radius: buttonFrame.radius
        color: "transparent"
        border.width: root.selected ? 3 : 2
        border.color: root.glowColor
        visible: false
    }

    MultiEffect {
        anchors.fill: glowSource
        source: glowSource
        visible: true
        shadowEnabled: true
        shadowColor: root.glowColor
        shadowOpacity: root.highlighted ? 0.92 : 0.46
        shadowBlur: root.highlighted ? 0.82 : 0.58
        shadowScale: root.highlighted ? 1.035 : 1.018

        Behavior on shadowOpacity {
            NumberAnimation { duration: 140 }
        }

        Behavior on shadowBlur {
            NumberAnimation { duration: 140 }
        }
    }

    Rectangle {
        id: buttonFrame
        anchors.fill: parent
        radius: 8
        color: "#151515"
        border.width: root.selected ? 3 : 2
        border.color: root.glowColor
        clip: true
        scale: root.pressed ? 0.985 : 1.0

        Behavior on scale {
            NumberAnimation { duration: 90 }
        }

        Image {
            anchors.fill: parent
            source: root.imageSource
            fillMode: Image.PreserveAspectCrop
            sourceSize.width: root.width * 2
            sourceSize.height: root.height * 2
            smooth: true
            mipmap: true
            visible: root.imageSource !== ""
        }

        Rectangle {
            anchors.fill: parent
            color: root.pressed ? "#99111111" : "#77111111"
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            height: 82
            color: "#99111111"
        }

        Text {
            anchors.centerIn: parent
            width: parent.width - 48
            text: root.buttonText
            color: Theme.textPrimary
            font.family: Constants.font.family
            font.pixelSize: 36
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"
            border.width: root.selected ? 3 : 1
            border.color: Qt.rgba(root.glowColor.r, root.glowColor.g, root.glowColor.b, root.selected ? 1.0 : 0.72)
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onContainsMouseChanged: root.hovered = containsMouse
            onPressedChanged: root.pressed = pressed
            onClicked: root.clicked()
        }
    }
}
