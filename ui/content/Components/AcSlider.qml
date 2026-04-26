import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Effects
import Rx8_HeadUnit

Item {
    id: root

    property real from: 0
    property real to: 100
    property real value: 50
    property real stepSize: 1

    property bool vertical: true
    property bool gradientFill: false
    property bool useAccentGradient: false

    property real knobSize: vertical ? width : height
    property real trackThickness: vertical ? width : height

    property color trackColor: "#2b2b2b"
    property color fillColor: "#ffffff"

    property color handleColor: "#ffffff"
    property color handleBorderColor: "#111111"

    property color coldColor: "#2f80ff"
    property color hotColor: "#ff3b30"
    property color accentColor: Theme.accentColor

    property bool glowEnabled: true
    property real glowWidth: trackThickness * 0.9
    property real glowStrength: 1.0

    signal valueChangedByUser(real value)

    implicitWidth: vertical ? 42 : 320
    implicitHeight: vertical ? 320 : 42

    readonly property real range: Math.max(0.0001, root.to - root.from)
    readonly property real normalisedValue: Math.max(0, Math.min(1, (root.value - root.from) / root.range))

    readonly property real usableLength: root.vertical
                                       ? Math.max(1, track.height - root.knobSize)
                                       : Math.max(1, track.width - root.knobSize)

    readonly property real handleCenterX: root.vertical
                                          ? track.x + track.width / 2
                                          : track.x + root.knobSize / 2 + root.usableLength * root.normalisedValue

    readonly property real handleCenterY: root.vertical
                                          ? track.y + root.knobSize / 2 + root.usableLength * (1.0 - root.normalisedValue)
                                          : track.y + track.height / 2

    function gradientColorAt(t) {
        if (root.useAccentGradient)
            return Qt.tint(root.accentColor, Qt.rgba(1, 1, 1, 0.12 * t))

        return Qt.rgba(
            root.hotColor.r * t + root.coldColor.r * (1.0 - t),
            root.hotColor.g * t + root.coldColor.g * (1.0 - t),
            root.hotColor.b * t + root.coldColor.b * (1.0 - t),
            1.0
        )
    }

    function setFromPosition(mouseX, mouseY) {
        var raw

        if (root.vertical) {
            raw = 1.0 - Math.max(0, Math.min(1, (mouseY - track.y - root.knobSize / 2) / root.usableLength))
        } else {
            raw = Math.max(0, Math.min(1, (mouseX - track.x - root.knobSize / 2) / root.usableLength))
        }

        var newValue = root.from + raw * root.range

        if (root.stepSize > 0)
            newValue = Math.round(newValue / root.stepSize) * root.stepSize

        root.value = Math.max(root.from, Math.min(root.to, newValue))
        root.valueChangedByUser(root.value)
    }

    Rectangle {
        id: track
        anchors.centerIn: parent

        width: root.vertical ? root.trackThickness : root.width
        height: root.vertical ? root.height : root.trackThickness

        radius: Math.min(width, height) / 2
        color: root.trackColor
    }

    Item {
        id: fillClip

        x: track.x
        y: root.vertical ? root.handleCenterY : track.y

        width: root.vertical
               ? track.width
               : Math.max(0, root.handleCenterX - track.x)

        height: root.vertical
                ? Math.max(0, track.y + track.height - root.handleCenterY)
                : track.height

        clip: true

        Rectangle {
            id: fillShape

            x: 0
            y: root.vertical ? -(fillClip.y - track.y) : 0

            width: track.width
            height: track.height
            radius: track.radius

            color: root.gradientFill ? "transparent" : root.fillColor

            gradient: root.gradientFill ? fillGradient : null
        }

        Gradient {
            id: fillGradient
            orientation: root.vertical ? Gradient.Vertical : Gradient.Horizontal

            GradientStop {
                position: 1.0
                color: root.useAccentGradient
                       ? (root.vertical ? Qt.lighter(root.accentColor, 1.3)
                                        : Qt.darker(root.accentColor, 1.65))
                       : root.coldColor
            }

            GradientStop {
                position: 0.5
                color: root.useAccentGradient
                       ? root.accentColor
                       : Qt.rgba(1, 1, 1, 0.04)
            }

            GradientStop {
                position: 0.0
                color: root.useAccentGradient
                       ? (root.vertical ? Qt.darker(root.accentColor, 1.65)
                                        : Qt.lighter(root.accentColor, 1.3))
                       : root.hotColor
            }
        }

        Item {
            id: glowLayer
            anchors.fill: parent
            visible: root.glowEnabled
            clip: true

            // Glow fades sideways from centre outward.
            // No blur, so no square/rectangle edge at the bottom.
            Rectangle {
                id: glowSpread

                anchors.fill: parent
                radius: track.radius

                opacity: 0.55 * root.glowStrength

                gradient: Gradient {
                    orientation: root.vertical ? Gradient.Horizontal : Gradient.Vertical

                    GradientStop { position: 0.00; color: "transparent" }
                    GradientStop { position: 0.22; color: "transparent" }

                    GradientStop {
                        position: 0.42
                        color: root.gradientFill
                               ? (root.useAccentGradient
                                    ? Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.10)
                                    : Qt.rgba(root.hotColor.r, root.hotColor.g, root.hotColor.b, 0.08))
                               : Qt.rgba(root.fillColor.r, root.fillColor.g, root.fillColor.b, 0.10)
                    }

                    GradientStop {
                        position: 0.50
                        color: root.gradientFill
                               ? (root.useAccentGradient
                                    ? Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.16)
                                    : Qt.rgba(root.hotColor.r, root.hotColor.g, root.hotColor.b, 0.10))
                               : Qt.rgba(root.fillColor.r, root.fillColor.g, root.fillColor.b, 0.14)
                    }

                    GradientStop {
                        position: 0.58
                        color: root.gradientFill
                               ? (root.useAccentGradient
                                    ? Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.10)
                                    : Qt.rgba(root.coldColor.r, root.coldColor.g, root.coldColor.b, 0.08))
                               : Qt.rgba(root.fillColor.r, root.fillColor.g, root.fillColor.b, 0.10)
                    }

                    GradientStop { position: 0.78; color: "transparent" }
                    GradientStop { position: 1.00; color: "transparent" }
                }
            }

            Rectangle {
                id: glowBoost

                anchors.fill: parent
                radius: track.radius

                opacity: 0.18 * root.glowStrength

                gradient: Gradient {
                    orientation: root.vertical ? Gradient.Horizontal : Gradient.Vertical

                    GradientStop { position: 0.00; color: "transparent" }
                    GradientStop { position: 0.35; color: "transparent" }

                    GradientStop {
                        position: 0.50
                        color: root.useAccentGradient
                               ? Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.18)
                               : Qt.rgba(root.fillColor.r, root.fillColor.g, root.fillColor.b, 0.12)
                    }

                    GradientStop { position: 0.65; color: "transparent" }
                    GradientStop { position: 1.00; color: "transparent" }
                }
            }
        }
    }

    Rectangle {
        id: handle

        width: root.knobSize
        height: root.knobSize
        radius: width / 2

        x: root.handleCenterX - width / 2
        y: root.handleCenterY - height / 2

        color: root.handleColor
        border.width: 3
        border.color: root.handleBorderColor
    }

    MouseArea {
        anchors.fill: parent

        onPressed: function(mouse) {
            root.setFromPosition(mouse.x, mouse.y)
        }

        onPositionChanged: function(mouse) {
            if (pressed)
                root.setFromPosition(mouse.x, mouse.y)
        }
    }
}
