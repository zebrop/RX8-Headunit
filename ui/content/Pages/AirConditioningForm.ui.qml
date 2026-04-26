
/*
UI ONLY FILE — Qt Design Studio compatible
*/
import QtQuick 6.8
import QtQuick.Controls 6.8
import Rx8_HeadUnit
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
        source: Theme.acPageBackground
        fillMode: Image.PreserveAspectCrop
        smooth: true
        asynchronous: true
        visible: status === Image.Ready
    }

    Rectangle {
        anchors.fill: parent
        anchors.leftMargin: 0
        anchors.rightMargin: 0
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

    // ===== TOP MODE BUTTONS =====
    AcButton {
        x: 8
        y: 17
        width: 110
        height: 58
        text: qsTr("ECO")
        checkable: true
    }
    AcButton {
        x: 8
        y: 92
        width: 110
        height: 58
        text: qsTr("Ambient")
        checkable: true
    }
    AcButton {
        x: 8
        y: 168
        width: 110
        height: 58
        text: qsTr("Normal")
        checkable: true
        checked: true
    }

    // ===== SLIDERS =====
    AcSlider {
        id: temperatureSlider
        x: 135
        y: 249
        width: 500
        height: 50
        from: 16
        to: 30
        value: 22
        stepSize: 0.5
        gradientFill: true
    }

    AcSlider {
        id: fanSlider
        x: 715
        y: 249
        width: 500
        height: 50
        from: 0
        to: 7
        value: 0
        stepSize: 1
    }

    Text {
        x: 275
        y: 212
        text: qsTr("Temperature")
        color: Theme.textPrimary
        font.family: Constants.font.family
        font.pixelSize: 20
    }

    Text {
        x: 898
        y: 212
        text: qsTr("Fan Speed")
        color: Theme.textPrimary
        font.family: Constants.font.family
        font.pixelSize: 20
    }

    // ===== AIRFLOW BUTTONS =====
    AcButton {
        id: faceButton
        x: 140
        y: 364
        width: 150
        height: 100
        text: qsTr("Face")
        checkable: true
    }
    AcButton {
        id: faceFeetButton
        x: 354
        y: 364
        width: 150
        height: 100
        text: qsTr("Face/Feet")
        checkable: true
    }
    AcButton {
        id: feetButton
        x: 569
        y: 364
        width: 150
        height: 100
        text: qsTr("Feet")
        checkable: true
    }
    AcButton {
        id: feetDemistButton
        x: 786
        y: 364
        width: 150
        height: 100
        text: qsTr("Feet/Demist")
        checkable: true
    }
    AcButton {
        id: demistFrontButton
        x: 987
        y: 364
        width: 150
        height: 100
        text: qsTr("Demist Front")
        checkable: true
    }

    // ===== SWITCHES =====
    AcButton {
        id: autoButton
        x: 390
        y: 562
        width: 114
        height: 72
        text: qsTr("AUTO")
        checkable: true
    }
    AcButton {
        id: acButton
        x: 587
        y: 562
        width: 114
        height: 72
        text: qsTr("A/C")
        checkable: true
    }

    Text {
        x: 689
        y: 120
        text: qsTr("Recirc/Fresh")
        color: Theme.textPrimary
        font.pixelSize: 20
    }
    AcSwitch {
        id: recircSwitch
        x: 696
        y: 28
        width: 113
        height: 72
    }

    // ===== EXTRA =====
    AcButton {
        id: rearDemistButton
        x: 786
        y: 562
        width: 114
        height: 72
        text: qsTr("Demist Rear")
        checkable: true
    }
    AcButton {
        id: powerButton
        x: 1106
        y: 28
        width: 150
        height: 72
        text: qsTr("Power")
        checkable: true
        checked: true
    }
}
