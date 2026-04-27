import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Effects
import Rx8_HeadUnit

Item {
    id: root

    property string text: ""
    property url iconSource: ""
    property int iconSize: 26
    property bool checked: false
    property bool checkable: true

    property color normalColor: "#2b2b2b"
    property color pressedColor: "#3a3a3a"
    property color borderColor: "#ffffff"
    property color disabledColor: "#555555"

    property color selectedColor: Theme.accentColor
    property color checkedFillColor: Qt.rgba(selectedColor.r, selectedColor.g, selectedColor.b, 0.16)
    property color textColor: root.checked ? root.selectedColor : "#ffffff"
    property color iconColor: root.checked ? root.selectedColor : "#ffffff"

    property bool glowEnabled: true
    property int glowPadding: 8
    property real glowOpacity: 0.85
    property real glowBlur: 0.65
    property int rectRadius: 10

    readonly property bool glowActive: root.checked && root.glowEnabled
    readonly property color activeLineColor: root.glowActive ? root.selectedColor : root.borderColor

    signal clicked()

    implicitWidth: width
    implicitHeight: height + 28

    Column {
        anchors.centerIn: parent
        spacing: 6

        Item {
            id: buttonShell

            width: root.width
            height: root.height

            scale: mouseArea.pressed ? 0.96 : 1.0
            opacity: root.enabled ? 1.0 : 0.45

            Behavior on scale {
                NumberAnimation { duration: 90 }
            }

            // ===== BUTTON BACKGROUND =====
            Rectangle {
                id: buttonBackground
                anchors.fill: parent
                radius: root.rectRadius

                color: !root.enabled ? root.disabledColor
                      : mouseArea.pressed ? root.pressedColor
                      : root.checked ? root.checkedFillColor
                      : root.normalColor

                border.width: root.checked ? 2 : 1
                border.color: root.activeLineColor

                Behavior on color {
                    ColorAnimation { duration: 140 }
                }

                Behavior on border.color {
                    ColorAnimation { duration: 140 }
                }
            }

            // ===== RECTANGLE LINE GLOW =====
            Rectangle {
                id: buttonLineGlowSource
                anchors.fill: buttonBackground
                radius: buttonBackground.radius
                color: "transparent"
                border.width: buttonBackground.border.width
                border.color: root.selectedColor
                visible: false
            }

            MultiEffect {
                anchors.fill: buttonLineGlowSource
                source: buttonLineGlowSource
                visible: root.glowActive

                shadowEnabled: true
                shadowColor: root.selectedColor
                shadowOpacity: root.glowOpacity
                shadowBlur: root.glowBlur
                shadowScale: 1.02
            }

            // Redraw crisp line above the glow
            Rectangle {
                id: buttonLine
                anchors.fill: buttonBackground
                radius: buttonBackground.radius
                color: "transparent"
                border.width: buttonBackground.border.width
                border.color: root.activeLineColor

                Behavior on border.color {
                    ColorAnimation { duration: 140 }
                }
            }

            // ===== ICON SOURCE =====
            Image {
                id: iconSourceImage

                width: root.iconSize
                height: root.iconSize
                anchors.centerIn: parent

                source: root.iconSource
                fillMode: Image.PreserveAspectFit
                sourceSize.width: root.iconSize * 3
                sourceSize.height: root.iconSize * 3
                smooth: true
                mipmap: true
                visible: false
            }

            // ===== ICON GLOW =====
            MultiEffect {
                anchors.fill: iconSourceImage
                source: iconSourceImage
                visible: root.iconSource !== "" && root.glowActive

                colorization: 1.0
                colorizationColor: root.selectedColor

                shadowEnabled: true
                shadowColor: root.selectedColor
                shadowOpacity: root.glowOpacity
                shadowBlur: root.glowBlur
                shadowScale: 1.05
            }

            // ===== CRISP ICON =====
            MultiEffect {
                anchors.fill: iconSourceImage
                source: iconSourceImage
                visible: root.iconSource !== ""

                colorization: 1.0
                colorizationColor: root.iconColor

                shadowEnabled: false
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

        Text {
            text: root.text
            color: root.textColor
            font.family: Constants.font.family
            font.pixelSize: 18
            font.bold: root.checked
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter

            Behavior on color {
                ColorAnimation { duration: 140 }
            }
        }
    }
}
