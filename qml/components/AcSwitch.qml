import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Effects
import Rx8_HeadUnit

Item {
    id: root

    property string text: ""
    property bool checked: false

    property bool switchChangesColor: true

    property color offColor: "#2b2b2b"
    property color onColor: "#ffffff"
    property color thumbOffColor: "#ffffff"
    property color thumbOnColor: "#111111"
    property color textColor: "#ffffff"
    property color borderColor: "#ffffff"

    property url iconSource: ""
    property int iconSize: 48

    property color accentColor: Theme.accentColor

    property bool glowEnabled: true
    property bool permanentGlow: false
    property color glowColor: root.accentColor
    property real glowOpacity: 0.85
    property real glowBlur: 0.65

    readonly property bool glowActive: root.glowEnabled
                                      && (root.permanentGlow || root.checked || mouseArea.pressed)

    readonly property color activeLineColor: root.glowActive ? root.glowColor : root.borderColor

    property color iconColor: {
        if (root.glowActive)
            return root.glowColor

        if (!root.switchChangesColor)
            return root.thumbOffColor

        return root.checked ? root.thumbOnColor : root.thumbOffColor
    }

    property color thumbColor: {
        if (root.glowActive)
            return root.glowColor

        if (!root.switchChangesColor)
            return root.thumbOffColor

        return root.checked ? root.thumbOnColor : root.thumbOffColor
    }

    signal toggled(bool checked)

    implicitWidth: 260
    implicitHeight: 72

    opacity: root.enabled ? 1.0 : 0.45

    Row {
        anchors.fill: parent
        spacing: 16

        Item {
            id: switchShell

            width: 110
            height: 42
            anchors.verticalCenter: parent.verticalCenter

            // ===== TRACK BACKGROUND =====
            Rectangle {
                id: trackBackground
                anchors.fill: parent
                radius: height / 2

                color: {
                    if (!root.switchChangesColor)
                        return root.offColor

                    return root.checked ? root.onColor : root.offColor
                }

                border.width: root.glowActive ? 2 : 1
                border.color: root.activeLineColor

                Behavior on color {
                    ColorAnimation {
                        duration: 140
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on border.color {
                    ColorAnimation {
                        duration: 140
                        easing.type: Easing.OutCubic
                    }
                }
            }

            // ===== TRACK LINE GLOW =====
            Rectangle {
                id: trackLineGlowSource
                anchors.fill: trackBackground
                radius: trackBackground.radius
                color: "transparent"
                border.width: trackBackground.border.width
                border.color: root.glowColor
                visible: false
            }

            MultiEffect {
                anchors.fill: trackLineGlowSource
                source: trackLineGlowSource
                visible: root.glowActive

                shadowEnabled: true
                shadowColor: root.glowColor
                shadowOpacity: root.glowOpacity
                shadowBlur: root.glowBlur
                shadowScale: 1.03
            }

            // Redraw crisp track line above glow
            Rectangle {
                id: trackLine
                anchors.fill: trackBackground
                radius: trackBackground.radius
                color: "transparent"
                border.width: trackBackground.border.width
                border.color: root.activeLineColor

                Behavior on border.color {
                    ColorAnimation {
                        duration: 140
                        easing.type: Easing.OutCubic
                    }
                }
            }

            // ===== ICON SOURCE =====
            Image {
                id: iconSourceImage

                width: root.iconSize
                height: root.iconSize
                source: root.iconSource
                visible: false
                fillMode: Image.PreserveAspectFit
                anchors.verticalCenter: parent.verticalCenter

                x: root.checked
                   ? 10
                   : switchShell.width - width - 10

                smooth: true
                mipmap: true
                antialiasing: true
                sourceSize.width: root.iconSize * 3
                sourceSize.height: root.iconSize * 3
                cache: false

                Behavior on x {
                    NumberAnimation {
                        duration: 140
                        easing.type: Easing.OutCubic
                    }
                }
            }

            // ===== ICON GLOW =====
            MultiEffect {
                anchors.fill: iconSourceImage
                source: iconSourceImage
                visible: root.iconSource !== "" && root.glowActive

                colorization: 1.0
                colorizationColor: root.glowColor

                shadowEnabled: true
                shadowColor: root.glowColor
                shadowOpacity: root.glowOpacity
                shadowBlur: root.glowBlur
                shadowScale: 1.08
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

            // ===== THUMB =====
            Rectangle {
                id: thumb

                width: 34
                height: 34
                radius: width / 2
                y: 4

                x: root.checked ? switchShell.width - width - 4 : 4

                color: root.thumbColor

                Behavior on x {
                    NumberAnimation {
                        duration: 140
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 140
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }

        Text {
            text: root.text
            color: root.textColor
            font.family: Constants.font.family
            font.pixelSize: 18
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: root.enabled

        onClicked: {
            root.checked = !root.checked
            root.toggled(root.checked)
        }
    }
}
