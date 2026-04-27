
/*
UI ONLY FILE — Qt Design Studio compatible
*/
import QtQuick 6.8
import QtQuick.Controls 6.8
import Rx8_HeadUnit
import QtQuick.Shapes 6.8
import "../Components"

Rectangle {
    id: root

    width: 1280
    height: 800
    color: Constants.backgroundColor

    Image {
        id: pageBackground
        anchors.fill: parent
        anchors.leftMargin: 0
        anchors.rightMargin: 0
        anchors.topMargin: 0
        anchors.bottomMargin: 0
        source: Qt.resolvedUrl("../../assets/backgrounds/simple_dark.jpg")
        fillMode: Image.PreserveAspectCrop
        smooth: true
        asynchronous: true
        visible: status === Image.Ready

        Rectangle {
            id: rectangle1
            x: 811
            y: 100
            width: 20
            height: 20
            radius: 10
            color: "#333332"
        }

        Rectangle {
            id: rectangle2
            x: 811
            y: 140
            width: 20
            height: 20
            color: "#333332"
            radius: 10
        }

        Rectangle {
            id: rectangle3
            x: 811
            y: 60
            width: 20
            height: 20
            color: "#333332"
            radius: 10
        }
    }

    Rectangle {
        id: rectangle
        x: 945
        y: 0
        width: 335
        height: 680
        color: "black"
        opacity: 0.4

        Rectangle {
            id: rectangle4
            x: 0
            y: 0
            width: 2
            height: 680
            color: "#88FFFFFF"
        }
    }

    Rectangle {
        anchors.fill: parent
        anchors.leftMargin: -72
        anchors.rightMargin: 72
        anchors.topMargin: 0
        anchors.bottomMargin: 0
        color: Constants.backgroundColor
        visible: pageBackground.status !== Image.Ready
    }

    // ===== EXPOSE COMPONENTS TO LOGIC FILE =====
    property alias faceButton: faceButton
    property alias faceFeetButton: faceFeetButton
    property alias feetButton: feetButton
    property alias feetDemistButton: feetDemistButton
    property alias demistFrontButton: demistFrontButton

    property alias temperatureSlider: temperatureSlider
    property alias fanSlider: fanSlider

    property alias autoButton: autoButton
    property alias acButton: acButton
    property alias recircSwitch: recircSwitch
    property alias rearDemistButton: rearDemistButton
    property alias powerButton: powerButton

    property alias temperatureValueText: temperatureValueText
    property alias fanValueText: fanValueText

    // ===== TOP MODE BUTTONS =====

    // ===== SLIDERS =====
    AcSlider {
        id: temperatureSlider
        x: 78
        y: 142
        width: 48
        height: 495
        from: 16
        to: 30
        value: 22
        stepSize: 1
        gradientFill: true
        useAccentGradient: false
        vertical: true
    }

    AcSlider {
        id: fanSlider
        x: 237
        y: 142
        width: 48
        height: 495
        from: 0
        to: 7
        value: 0
        stepSize: 1
        vertical: true
        gradientFill: true
        useAccentGradient: true
    }

    Text {
        x: 44
        y: 34
        text: qsTr("Temperature")
        color: Theme.textPrimary
        font.family: Constants.font.family
        font.pixelSize: 20
    }

    Text {
        x: 215
        y: 37
        text: qsTr("Fan Speed")
        color: Theme.textPrimary
        font.family: Constants.font.family
        font.pixelSize: 20
    }

    // ===== AIRFLOW BUTTONS =====
    AcButton {
        id: faceButton
        x: 339
        y: 243
        width: 150
        height: 110
        checkable: true
        text: qsTr("Face")
    }
    AcButton {
        id: faceFeetButton
        x: 539
        y: 243
        width: 150
        height: 110
        checkable: true
        text: qsTr("Face/Feet")
    }
    AcButton {
        id: feetButton
        x: 739
        y: 243
        width: 150
        height: 110
        checkable: true
        text: qsTr("Feet")
    }
    AcButton {
        id: feetDemistButton
        x: 439
        y: 433
        width: 150
        height: 110
        checkable: true
        text: qsTr("Feet/Demist")
    }
    AcButton {
        id: demistFrontButton
        x: 639
        y: 433
        width: 150
        height: 110
        checkable: true
        text: qsTr("Demist")
    }

    // ===== SWITCHES =====
    AcButton {
        id: autoButton
        x: 1148
        y: 170
        width: 114
        height: 72
        checkable: true
    }
    AcButton {
        id: acButton
        x: 1148
        y: 300
        width: 114
        height: 72
        checkable: true
    }

    Text {
        x: 973
        y: 546
        text: qsTr("Fresh Air/ \nRecirculate")
        color: Theme.textPrimary
        font.pixelSize: 28
    }
    AcSwitch {
        id: recircSwitch
        x: 1148
        y: 554
        width: 114
        height: 51
        switchChangesColor: false
        permanentGlow: true
    }

    // ===== EXTRA =====
    AcButton {
        id: rearDemistButton
        x: 1148
        y: 430
        width: 114
        height: 72
        checkable: true
    }

    AcButton {
        id: powerButton
        x: 1165
        y: 34
        width: 80
        height: 80
        checkable: true
        checked: true
        rectRadius: 50
    }

    Text {
        id: temperatureValueText
        x: 61
        y: 70
        color: Theme.textPrimary
        text: qsTr("%1°C").arg(Math.round(temperatureSlider.value))
        font.pixelSize: 40
        font.family: Constants.font.family
    }

    Text {
        id: fanValueText
        x: 249
        y: 73
        color: Theme.textPrimary
        text: qsTr("%1").arg(Math.round(fanSlider.value))
        font.pixelSize: 40
        font.family: Constants.font.family
    }

    Text {
        x: 845
        y: 98
        color: Theme.textPrimary
        text: qsTr("Normal")
        font.pixelSize: 20
        font.family: Constants.font.family
    }

    Text {
        x: 845
        y: 138
        color: Theme.textPrimary
        text: qsTr("Ambient")
        font.pixelSize: 20
        font.family: Constants.font.family
    }

    Text {
        x: 845
        y: 57
        color: Theme.textPrimary
        text: qsTr("ECO")
        font.pixelSize: 20
        font.family: Constants.font.family
    }

    Text {
        x: 966
        y: 189
        color: Theme.textPrimary
        text: qsTr("Auto")
        font.pixelSize: 28
        font.family: Constants.font.family
    }

    Text {
        x: 973
        y: 323
        color: Theme.textPrimary
        text: qsTr("A/C")
        font.pixelSize: 28
        font.family: Constants.font.family
    }

    Text {
        x: 973
        y: 449
        color: Theme.textPrimary
        text: "Rear Demist"
        font.pixelSize: 28
        font.family: Constants.font.family
        horizontalAlignment: Text.AlignHCenter
    }

    Text {
        x: 966
        y: 57
        color: Theme.textPrimary
        text: qsTr("Power")
        font.pixelSize: 28
        font.family: Constants.font.family
    }
}
