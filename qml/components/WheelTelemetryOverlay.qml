import QtQuick 6.8
import QtQuick.Shapes 6.8
import Rx8_HeadUnit

Item {
    id: root

    property Item vehicleGroup
    property Item frontLeftWheel
    property Item frontRightWheel
    property Item rearLeftWheel
    property Item rearRightWheel
    readonly property real vehicleLocalWidth: 780
    readonly property real vehicleLocalHeight: 410
    readonly property real vehicleOriginX: vehicleLocalWidth / 2
    readonly property real vehicleOriginY: vehicleLocalHeight / 2
    readonly property real vehicleScale: vehicleGroup ? vehicleGroup.scale : 1
    readonly property real vehicleAngle: (vehicleGroup ? vehicleGroup.rotation : 0) * Math.PI / 180
    readonly property real vehicleCos: Math.cos(vehicleAngle)
    readonly property real vehicleSin: Math.sin(vehicleAngle)

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeWidth: 2
            strokeColor: Theme.accent
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            startX: frontLeftWheelTelemetry.wheelX
            startY: frontLeftWheelTelemetry.wheelY

            PathLine {
                x: frontLeftWheelTelemetry.x + frontLeftWheelTelemetry.width
                y: frontLeftWheelTelemetry.y + frontLeftWheelTelemetry.height / 2
            }
        }

        ShapePath {
            strokeWidth: 2
            strokeColor: Theme.accent
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            startX: frontRightWheelTelemetry.wheelX
            startY: frontRightWheelTelemetry.wheelY

            PathLine {
                x: frontRightWheelTelemetry.x
                y: frontRightWheelTelemetry.y + frontRightWheelTelemetry.height / 2
            }
        }

        ShapePath {
            strokeWidth: 2
            strokeColor: Theme.accent
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            startX: rearLeftWheelTelemetry.wheelX
            startY: rearLeftWheelTelemetry.wheelY

            PathLine {
                x: rearLeftWheelTelemetry.x + rearLeftWheelTelemetry.width
                y: rearLeftWheelTelemetry.y + rearLeftWheelTelemetry.height / 2
            }
        }

        ShapePath {
            strokeWidth: 2
            strokeColor: Theme.accent
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            startX: rearRightWheelTelemetry.wheelX
            startY: rearRightWheelTelemetry.wheelY

            PathLine {
                x: rearRightWheelTelemetry.x
                y: rearRightWheelTelemetry.y + rearRightWheelTelemetry.height / 2
            }
        }
    }

    Rectangle {
        id: frontLeftWheelTelemetry
        readonly property real localX: root.frontLeftWheel ? root.frontLeftWheel.x + root.frontLeftWheel.width / 2 : 0
        readonly property real localY: root.frontLeftWheel ? root.frontLeftWheel.y + root.frontLeftWheel.height / 2 : 0
        readonly property real wheelX: (root.vehicleGroup ? root.vehicleGroup.x : 0) + root.vehicleOriginX + ((localX - root.vehicleOriginX) * root.vehicleCos - (localY - root.vehicleOriginY) * root.vehicleSin) * root.vehicleScale
        readonly property real wheelY: (root.vehicleGroup ? root.vehicleGroup.y : 0) + root.vehicleOriginY + ((localX - root.vehicleOriginX) * root.vehicleSin + (localY - root.vehicleOriginY) * root.vehicleCos) * root.vehicleScale

        x: wheelX - 160
        y: wheelY - 52
        width: 112
        height: 52
        radius: 8
        color: "#dd111117"
        border.color: Theme.accent
        border.width: 2

        Rectangle {
            x: parent.width - 5
            y: parent.height / 2 - 5
            width: 10
            height: 10
            radius: 5
            color: Theme.accent
        }

        Text {
            x: 10
            y: 6
            text: "FL"
            color: Theme.textMuted
            font.pixelSize: 12
            font.bold: true
        }

        Text {
            x: 36
            y: 5
            text: "0.0°"
            color: Theme.textPrimary
            font.pixelSize: 16
            font.bold: true
        }

        Text {
            x: 10
            y: 29
            text: "0 km/h"
            color: Theme.accent
            font.pixelSize: 15
            font.bold: true
        }
    }

    Rectangle {
        id: frontRightWheelTelemetry
        readonly property real localX: root.frontRightWheel ? root.frontRightWheel.x + root.frontRightWheel.width / 2 : 0
        readonly property real localY: root.frontRightWheel ? root.frontRightWheel.y + root.frontRightWheel.height / 2 : 0
        readonly property real wheelX: (root.vehicleGroup ? root.vehicleGroup.x : 0) + root.vehicleOriginX + ((localX - root.vehicleOriginX) * root.vehicleCos - (localY - root.vehicleOriginY) * root.vehicleSin) * root.vehicleScale
        readonly property real wheelY: (root.vehicleGroup ? root.vehicleGroup.y : 0) + root.vehicleOriginY + ((localX - root.vehicleOriginX) * root.vehicleSin + (localY - root.vehicleOriginY) * root.vehicleCos) * root.vehicleScale

        x: wheelX - width + 160
        y: wheelY - 52
        width: 112
        height: 52
        radius: 8
        color: "#dd111117"
        border.color: Theme.accent
        border.width: 2

        Rectangle {
            x: - 5
            y: parent.height / 2 - 5
            width: 10
            height: 10
            radius: 5
            color: Theme.accent
        }

        Text {
            x: 10
            y: 6
            text: "FR"
            color: Theme.textMuted
            font.pixelSize: 12
            font.bold: true
        }

        Text {
            x: 36
            y: 5
            text: "0.0°"
            color: Theme.textPrimary
            font.pixelSize: 16
            font.bold: true
        }

        Text {
            x: 10
            y: 29
            text: "0 km/h"
            color: Theme.accent
            font.pixelSize: 15
            font.bold: true
        }
    }

    Rectangle {
        id: rearLeftWheelTelemetry
        readonly property real localX: root.rearLeftWheel ? root.rearLeftWheel.x + root.rearLeftWheel.width / 2 : 0
        readonly property real localY: root.rearLeftWheel ? root.rearLeftWheel.y + root.rearLeftWheel.height / 2 : 0
        readonly property real wheelX: (root.vehicleGroup ? root.vehicleGroup.x : 0) + root.vehicleOriginX + ((localX - root.vehicleOriginX) * root.vehicleCos - (localY - root.vehicleOriginY) * root.vehicleSin) * root.vehicleScale
        readonly property real wheelY: (root.vehicleGroup ? root.vehicleGroup.y : 0) + root.vehicleOriginY + ((localX - root.vehicleOriginX) * root.vehicleSin + (localY - root.vehicleOriginY) * root.vehicleCos) * root.vehicleScale

        x: wheelX - 160
        y: wheelY
        width: 112
        height: 52
        radius: 8
        color: "#dd111117"
        border.color: Theme.accent
        border.width: 2

        Rectangle {
            x: parent.width - 5
            y: parent.height / 2 - 5
            width: 10
            height: 10
            radius: 5
            color: Theme.accent
        }

        Text {
            x: 10
            y: 6
            text: "RL"
            color: Theme.textMuted
            font.pixelSize: 12
            font.bold: true
        }

        Text {
            x: 36
            y: 5
            text: "0.0°"
            color: Theme.textPrimary
            font.pixelSize: 16
            font.bold: true
        }

        Text {
            x: 10
            y: 29
            text: "0 km/h"
            color: Theme.accent
            font.pixelSize: 15
            font.bold: true
        }
    }

    Rectangle {
        id: rearRightWheelTelemetry
        readonly property real localX: root.rearRightWheel ? root.rearRightWheel.x + root.rearRightWheel.width / 2 : 0
        readonly property real localY: root.rearRightWheel ? root.rearRightWheel.y + root.rearRightWheel.height / 2 : 0
        readonly property real wheelX: (root.vehicleGroup ? root.vehicleGroup.x : 0) + root.vehicleOriginX + ((localX - root.vehicleOriginX) * root.vehicleCos - (localY - root.vehicleOriginY) * root.vehicleSin) * root.vehicleScale
        readonly property real wheelY: (root.vehicleGroup ? root.vehicleGroup.y : 0) + root.vehicleOriginY + ((localX - root.vehicleOriginX) * root.vehicleSin + (localY - root.vehicleOriginY) * root.vehicleCos) * root.vehicleScale

        x: wheelX - width + 160
        y: wheelY
        width: 112
        height: 52
        radius: 8
        color: "#dd111117"
        border.color: Theme.accent
        border.width: 2

        Rectangle {
            x: - 5
            y: parent.height / 2 - 5
            width: 10
            height: 10
            radius: 5
            color: Theme.accent
        }

        Text {
            x: 10
            y: 6
            text: "RR"
            color: Theme.textMuted
            font.pixelSize: 12
            font.bold: true
        }

        Text {
            x: 36
            y: 5
            text: "0.0°"
            color: Theme.textPrimary
            font.pixelSize: 16
            font.bold: true
        }

        Text {
            x: 10
            y: 29
            text: "0 km/h"
            color: Theme.accent
            font.pixelSize: 15
            font.bold: true
        }
    }
}
