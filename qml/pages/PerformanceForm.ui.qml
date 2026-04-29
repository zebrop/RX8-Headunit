
/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML. If you edit
this file manually, you might introduce QML code that is not supported by Qt Design Studio.
Check out https://doc.qt.io/qtcreator/creator-quick-ui-forms.html for details on .ui.qml files.
*/
import QtQuick 6.8
import QtQuick.Controls 6.8
import Rx8_HeadUnit
import QtQuick.Studio.Components 1.0
import QtQuick.Shapes 6.8

Rectangle {
    id: root
    width: 1280
    height: 800

    readonly property url engineSource: Qt.resolvedUrl("../../assets/car/13b.svg")
    readonly property url drivetrainSource: Qt.resolvedUrl("../../assets/car/drivetrain.svg")
    readonly property url shellWireframeSource: Qt.resolvedUrl("../../assets/car/Shell_Wireframe.svg")
    readonly property url wheelSource: Qt.resolvedUrl("../../assets/car/wheel.svg")
    readonly property real vehicleSvgRasterScale: 3
    property alias frontLeftWheelItem: frontLeftWheel
    property alias frontRightWheelItem: frontRightWheel
    property alias rearLeftWheelItem: rearLeftWheel
    property alias rearRightWheelItem: rearRightWheel
    property alias vehicleGroupItem: vehicleGroupId

    color: Theme.backgroundColor

    Image {
        id: pageBackground
        x: 0
        y: 0
        width: root.width
        height: root.height
        source: Theme.performancePageBackground
        fillMode: Image.PreserveAspectCrop
        smooth: true
        asynchronous: true
        visible: status === Image.Ready

        // ── G-Force ──────────────────────────────────────────────────────────
        Rectangle {
            id: gForces
            x: 992
            y: 272
            width: 280
            height: 170
            color: "#dd111117"
            radius: 16
            border.color: Theme.accent
            border.width: 2

            Text {
                x: 18
                y: 12
                text: "G-Force"
                color: Theme.textPrimary
                font.pixelSize: 17
                font.bold: true
                font.family: Constants.font.family
            }

            Rectangle {
                x: 55
                y: 42
                width: 96
                height: 96
                radius: 48
                color: "transparent"
                border.color: "#44ffffff"
                border.width: 2
            }
            Rectangle {
                x: 74
                y: 61
                width: 58
                height: 58
                radius: 29
                color: "transparent"
                border.color: "#44ffffff"
                border.width: 2
            }
            Rectangle {
                x: 102
                y: 42
                width: 2
                height: 96
                color: "#33ffffff"
            }
            Rectangle {
                x: 55
                y: 89
                width: 96
                height: 2
                color: "#33ffffff"
            }
            Rectangle {
                x: 97
                y: 84
                width: 12
                height: 12
                radius: 6
                color: Theme.accent
            }

            Text {
                x: 157
                y: 34
                text: "Lateral G"
                color: Theme.textMuted
                font.pixelSize: 14
                font.bold: true
                font.family: Constants.font.family
            }
            Text {
                x: 157
                y: 57
                text: "0.41g"
                color: Theme.textPrimary
                font.pixelSize: 24
                font.bold: true
            }
            Text {
                x: 157
                y: 92
                text: "Longitudinal G"
                color: Theme.textMuted
                font.pixelSize: 14
                font.bold: true
                font.family: Constants.font.family
            }
            Text {
                x: 157
                y: 116
                text: "0.25g"
                color: Theme.textPrimary
                font.pixelSize: 24
                font.bold: true
            }
        }

        // ── Fluid Temps ──────────────────────────────────────────────────────
        Rectangle {
            id: fluidtemps
            x: 8
            y: 201
            width: 170
            height: 385
            color: "#dd111117"
            radius: 16
            border.color: Theme.accent
            border.width: 2

            Text {
                x: 16
                y: 16
                text: "Oil Temp"
                color: Theme.textMuted
                font.pixelSize: 16
                font.bold: true
                font.family: Constants.font.family
            }
            Text {
                x: 58
                y: 36
                text: "107°c"
                color: Theme.textPrimary
                font.pixelSize: 24
                font.bold: true
            }
            Rectangle {
                x: 14
                y: 76
                width: 142
                height: 2
                color: "#33ffffff"
            }

            Text {
                x: 16
                y: 94
                text: "Oil Pressure"
                color: Theme.textMuted
                font.pixelSize: 16
                font.bold: true
                font.family: Constants.font.family
            }
            Text {
                x: 58
                y: 114
                text: "4.6 bar"
                color: Theme.textPrimary
                font.pixelSize: 23
                font.bold: true
            }
            Rectangle {
                x: 14
                y: 154
                width: 142
                height: 2
                color: "#33ffffff"
            }

            Text {
                x: 16
                y: 172
                text: "Coolant Temp"
                color: Theme.textMuted
                font.pixelSize: 16
                font.bold: true
                font.family: Constants.font.family
            }
            Text {
                x: 58
                y: 192
                text: "91°c"
                color: Theme.textPrimary
                font.pixelSize: 24
                font.bold: true
            }
            Rectangle {
                x: 14
                y: 232
                width: 142
                height: 2
                color: "#33ffffff"
            }

            Text {
                x: 16
                y: 248
                text: "Voltage"
                color: Theme.textMuted
                font.pixelSize: 16
                font.bold: true
                font.family: Constants.font.family
            }
            Text {
                x: 58
                y: 268
                text: "14.0v"
                color: Theme.textPrimary
                font.pixelSize: 22
                font.bold: true
            }
        }

        // ── Vertical Tachometer ───────────────────────────────────────────────
        Rectangle {
            id: verticalTachometer
            x: 874
            y: 8
            width: 112
            height: 571
            radius: 16
            color: "#ee111117"
            border.color: Theme.accent
            border.width: 3

            property real currentRpm: 6500
            readonly property real maxRpm: 10000
            readonly property real redlineRpm: 8500
            readonly property real rpmPercent: currentRpm / maxRpm
            readonly property real redlinePercent: redlineRpm / maxRpm

            Text {
                x: 0
                y: 12
                width: parent.width
                height: 18
                text: "RPM"
                color: Theme.textPrimary
                font.pixelSize: 17
                font.bold: true
                font.family: Constants.font.family
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                x: 0
                y: 31
                width: parent.width
                height: 16
                text: "x1000"
                color: Theme.textMuted
                font.pixelSize: 12
                font.family: Constants.font.family
                horizontalAlignment: Text.AlignHCenter
            }

            Rectangle {
                id: tachTrackGlow
                x: 39
                y: 58
                width: 34
                height: 448
                radius: 17
                color: Theme.controlSelected
            }

            Rectangle {
                id: tachTrack
                x: 45
                y: 64
                width: 22
                height: 436
                radius: 11
                color: "#44000000"
                border.color: "#33ffffff"
                border.width: 1

                Rectangle {
                    x: 0
                    y: 0
                    width: parent.width
                    height: tachTrack.height * (1 - verticalTachometer.redlinePercent)
                    radius: 10
                    color: "#44ff174f"
                }

                Rectangle {
                    x: 3
                    y: 3 + (tachTrack.height - 6) * (1 - verticalTachometer.rpmPercent)
                    width: 16
                    height: (tachTrack.height - 6) * verticalTachometer.rpmPercent
                    radius: 8
                    gradient: Gradient {
                        GradientStop {
                            position: 0.0
                            color: verticalTachometer.currentRpm
                                   >= verticalTachometer.redlineRpm ? "#ff6a00" : Theme.accent
                        }
                        GradientStop {
                            position: 1.0
                            color: Theme.accent
                        }
                    }
                }

                Rectangle {
                    x: -7
                    y: tachTrack.height * (1 - verticalTachometer.redlinePercent) - 1
                    width: 36
                    height: 2
                    radius: 1
                    color: "#ff174f"
                }
            }

            Text {
                x: 14
                y: 58
                text: "10"
                color: Theme.textPrimary
                font.pixelSize: 13
                font.bold: true
            }

            Text {
                x: 8
                y: 123
                text: "8.5"
                color: "#ff7a9b"
                font.pixelSize: 12
                font.bold: true
            }

            Text {
                x: 19
                y: 276
                text: "5"
                color: Theme.textMuted
                font.pixelSize: 13
                font.bold: true
            }

            Text {
                x: 20
                y: 494
                text: "0"
                color: Theme.textMuted
                font.pixelSize: 13
                font.bold: true
            }

            Rectangle {
                x: 76
                y: 64
                width: 12
                height: 2
                radius: 1
                color: "#80ffffff"
            }

            Rectangle {
                x: 76
                y: 129
                width: 12
                height: 2
                radius: 1
                color: "#ccff174f"
            }

            Rectangle {
                x: 76
                y: 282
                width: 12
                height: 2
                radius: 1
                color: "#669d91aa"
            }

            Rectangle {
                x: 76
                y: 500
                width: 12
                height: 2
                radius: 1
                color: "#669d91aa"
            }

            Text {
                x: 10
                y: 518
                width: 92
                height: 28
                text: "6500"
                color: Theme.textPrimary
                font.pixelSize: 23
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                x: 10
                y: 546
                width: 92
                height: 16
                text: "rpm"
                color: Theme.textMuted
                font.pixelSize: 13
                font.family: Constants.font.family
                horizontalAlignment: Text.AlignHCenter
            }
        }

        // ── Pedal Positions ───────────────────────────────────────────────────
        Rectangle {
            id: pedalpositions
            x: 992
            y: 145
            width: 280
            height: 121
            color: "#dd111117"
            radius: 16
            border.color: Theme.accent
            border.width: 2

            Text {
                x: 18
                y: 14
                text: "Throttle Position"
                color: Theme.textMuted
                font.pixelSize: 16
                font.bold: true
                font.family: Constants.font.family
            }
            Text {
                x: 228
                y: 14
                text: "78%"
                color: Theme.textPrimary
                font.pixelSize: 16
                font.bold: true
            }
            Rectangle {
                x: 18
                y: 42
                width: 240
                height: 10
                radius: 5
                color: "#33ffffff"
            }
            Rectangle {
                x: 18
                y: 42
                width: 187
                height: 10
                radius: 5
                color: Theme.accent
            }

            Text {
                x: 18
                y: 66
                text: "Brake Position"
                color: Theme.textMuted
                font.pixelSize: 16
                font.bold: true
                font.family: Constants.font.family
            }
            Text {
                x: 236
                y: 66
                text: "8%"
                color: Theme.textPrimary
                font.pixelSize: 16
                font.bold: true
            }
            Rectangle {
                x: 18
                y: 94
                width: 240
                height: 10
                radius: 5
                color: "#33ffffff"
            }
            Rectangle {
                x: 18
                y: 94
                width: 20
                height: 10
                radius: 5
                color: Theme.danger
            }
        }

        // ── Air / Engine Temps ────────────────────────────────────────────────
        Rectangle {
            id: airtemps
            x: 992
            y: 8
            width: 280
            height: 131
            color: "#dd111117"
            radius: 16
            border.color: Theme.accent
            border.width: 2

            Text {
                x: 18
                y: 14
                text: "Ambient Temp"
                color: Theme.textMuted
                font.pixelSize: 16
                font.bold: true
                font.family: Constants.font.family
            }
            Text {
                x: 208
                y: 14
                text: "37°c"
                color: Theme.textPrimary
                font.pixelSize: 19
                font.bold: true
            }

            Text {
                x: 18
                y: 52
                text: "IAT"
                color: Theme.textMuted
                font.pixelSize: 16
                font.bold: true
                font.family: Constants.font.family
            }
            Text {
                x: 208
                y: 52
                text: "42°c"
                color: Theme.textPrimary
                font.pixelSize: 19
                font.bold: true
            }

            Text {
                x: 18
                y: 90
                text: "EGT"
                color: Theme.textMuted
                font.pixelSize: 16
                font.bold: true
                font.family: Constants.font.family
            }
            Text {
                x: 208
                y: 90
                text: "760°c"
                color: Theme.textPrimary
                font.pixelSize: 19
                font.bold: true
            }
        }

        // ── Vehicle Speed ─────────────────────────────────────────────────────
        Rectangle {
            id: fuel1
            x: 992
            y: 448
            width: 134
            height: 131
            color: "#cc111117"
            radius: 16
            border.color: Theme.accent
            border.width: 2

            Text {
                x: 5
                y: 11
                width: 124
                height: 18
                color: Theme.textMuted
                text: "Vehicle Speed"
                font.pixelSize: 15
                font.bold: true
                font.family: Constants.font.family
            }

            Text {
                x: 36
                y: 35
                color: Theme.textPrimary
                text: "179"
                font.pixelSize: 40
                font.bold: true
            }

            Text {
                x: 33
                y: 91
                width: 68
                height: 32
                color: Theme.textPrimary
                text: "km/h"
                font.pixelSize: 28
            }
        }

        // ── Fuel ──────────────────────────────────────────────────────────────
        Rectangle {
            id: fuel
            x: 8
            y: 8
            width: 234
            height: 187
            color: "#ee111117"
            radius: 16
            border.width: 2
            border.color: Theme.accent

            Text {
                x: 17
                y: 8
                text: "Fuel"
                color: Theme.textMuted
                font.pixelSize: 15
                font.bold: true
                font.family: Constants.font.family
            }
            Rectangle {
                x: 63
                y: 8
                width: 157
                height: 21
                radius: 5
                color: "#44000000"
            }
            Rectangle {
                x: 63
                y: 8
                width: 89
                height: 21
                radius: 5
                color: Theme.accent
            }
            Text {
                x: 17
                y: 47
                text: "Fuel Consumption"
                color: Theme.textMuted
                font.pixelSize: 15
                font.bold: true
                font.family: Constants.font.family
            }
            Text {
                x: 17
                y: 62
                text: "INSTANT"
                color: Theme.textMuted
                font.pixelSize: 15
                font.family: Constants.font.family
            }
            Text {
                x: 181
                y: 40
                text: "9.1"
                color: Theme.textPrimary
                font.pixelSize: 26
                font.bold: true
            }
            Text {
                x: 170
                y: 69
                text: "L/100km"
                color: Theme.textPrimary
                font.pixelSize: 14
            }
            Text {
                x: 17
                y: 95
                text: "Fuel Consumption"
                color: Theme.textMuted
                font.pixelSize: 15
                font.bold: true
                font.family: Constants.font.family
            }
            Text {
                x: 17
                y: 110
                text: "AVERAGE"
                color: Theme.textMuted
                font.pixelSize: 15
                font.family: Constants.font.family
            }
            Text {
                x: 180
                y: 88
                text: "7.2"
                color: Theme.textPrimary
                font.pixelSize: 26
                font.bold: true
            }
            Text {
                x: 172
                y: 116
                text: "L/100km"
                color: Theme.textPrimary
                font.pixelSize: 14
            }
            Text {
                x: 17
                y: 145
                text: "Range"
                color: Theme.textMuted
                font.pixelSize: 15
                font.bold: true
                font.family: Constants.font.family
            }
            Text {
                x: 176
                y: 138
                text: "328"
                color: Theme.textPrimary
                font.pixelSize: 26
                font.bold: true
            }
            Text {
                x: 188
                y: 164
                text: "km"
                color: Theme.textPrimary
                font.pixelSize: 14
            }
            Text {
                x: 110
                y: 8
                width: 42
                height: 21
                text: "55%"
                color: Theme.textPrimary
                font.pixelSize: 18
                font.bold: true
            }
        }

        // ── Engine Codes ──────────────────────────────────────────────────────
        Rectangle {
            id: airtemps1
            x: 1132
            y: 448
            width: 140
            height: 131
            color: "#dd111117"
            radius: 16
            border.color: Theme.accent
            border.width: 2

            Text {
                x: 9
                y: 8
                color: Theme.textMuted
                text: "Engine Codes"
                font.pixelSize: 16
                font.bold: true
                font.family: Constants.font.family
            }

            Text {
                x: 59
                y: 46
                width: 23
                height: 39
                color: Theme.success
                text: "0"
                font.pixelSize: 32
                font.bold: true
            }
        }
    }

    // ── Vehicle diagram ────────────────────────────────────────────────────────
    GroupItem {
        id: vehicleGroupId
        x: 162
        y: 101
        rotation: 90
        scale: 0.7

        Image {
            id: shellWireframe
            x: 0
            y: 26
            width: 780
            height: 360
            visible: true
            source: root.shellWireframeSource
            sourceSize.width: width * root.vehicleSvgRasterScale
            sourceSize.height: height * root.vehicleSvgRasterScale
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
            antialiasing: true
            asynchronous: true
        }

        Image {
            id: engine13b
            x: 90
            y: 156
            width: 180
            height: 100
            source: root.engineSource
            sourceSize.width: width * root.vehicleSvgRasterScale
            sourceSize.height: height * root.vehicleSvgRasterScale
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
            antialiasing: true
            asynchronous: true
            visible: status === Image.Ready
        }

        Image {
            id: drivetrain
            x: 224
            y: 82
            width: 432
            height: 244
            source: root.drivetrainSource
            sourceSize.width: width * root.vehicleSvgRasterScale
            sourceSize.height: height * root.vehicleSvgRasterScale
            smooth: true
            mipmap: true
            antialiasing: true
            asynchronous: true
            visible: status === Image.Ready
        }

        Image {
            id: frontLeftWheel
            x: 85
            y: 290
            width: 120
            height: 120
            source: root.wheelSource
            sourceSize.width: width * root.vehicleSvgRasterScale
            sourceSize.height: height * root.vehicleSvgRasterScale
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
            antialiasing: true
            asynchronous: true
            visible: status === Image.Ready
            rotation: 90
            mirror: true
        }

        Image {
            id: frontRightWheel
            x: 85
            y: 0
            width: 120
            height: 120
            source: root.wheelSource
            sourceSize.width: width * root.vehicleSvgRasterScale
            sourceSize.height: height * root.vehicleSvgRasterScale
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
            antialiasing: true
            asynchronous: true
            visible: status === Image.Ready
            rotation: 90
        }

        Image {
            id: rearLeftWheel
            x: 568
            y: 290
            width: 120
            height: 120
            source: root.wheelSource
            sourceSize.width: width * root.vehicleSvgRasterScale
            sourceSize.height: height * root.vehicleSvgRasterScale
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
            antialiasing: true
            asynchronous: true
            visible: status === Image.Ready
            rotation: 90
            mirror: true
        }

        Image {
            id: rearRightWheel
            x: 568
            y: 0
            width: 120
            height: 120
            source: root.wheelSource
            sourceSize.width: width * root.vehicleSvgRasterScale
            sourceSize.height: height * root.vehicleSvgRasterScale
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
            antialiasing: true
            asynchronous: true
            visible: status === Image.Ready
            rotation: 90
        }
    }
}
