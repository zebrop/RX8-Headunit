

/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML. If you edit
this file manually, you might introduce QML code that is not supported by Qt Design Studio.
Check out https://doc.qt.io/qtcreator/creator-quick-ui-forms.html for details on .ui.qml files.
*/
import QtQuick 6.8
import QtQuick.Controls 6.8
import Rx8_HeadUnit

Rectangle {
    width: Constants.width
    height: Constants.height

    color: Constants.backgroundColor

    Text {
        text: qsTr("A/C Page")
        anchors.verticalCenterOffset: -110
        anchors.horizontalCenterOffset: -20
        anchors.centerIn: parent
        font.family: Constants.font.family
    }

    ButtonGroup {
        id: airflowModeGroup
        exclusive: true
    }

    Slider {
        id: slider
        x: 697
        y: 113
        width: 500
        height: 50
        stepSize: 1
        orientation: Qt.Horizontal
        to: 16
        value: 0
    }

    Slider {
        id: slider1
        x: 86
        y: 113
        width: 500
        height: 50
        orientation: Qt.Horizontal
        stepSize: 1
        snapMode: RangeSlider.SnapOnRelease
        to: 7
        value: 0
    }

    Button {
        id: button
        x: 987
        y: 364
        width: 150
        height: 100
        text: qsTr("Demist Front")
        checkable: true
        ButtonGroup.group: airflowModeGroup
    }

    Button {
        id: button1
        x: 821
        y: 590
        checkable: true
    }

    Switch {
        id: switch1
        x: 529
        y: 586
        width: 229
        height: 28
    }

    Button {
        id: button3
        x: 140
        y: 364
        width: 150
        height: 100
        text: qsTr("Face")
        checkable: true
        ButtonGroup.group: airflowModeGroup
    }

    Button {
        id: button4
        x: 569
        y: 364
        width: 150
        height: 100
        text: qsTr("Feet")
        checkable: true
        ButtonGroup.group: airflowModeGroup
    }

    Button {
        id: button5
        x: 354
        y: 364
        width: 150
        height: 100
        text: qsTr("Face/Feet")
        checkable: true
        ButtonGroup.group: airflowModeGroup
    }

    Button {
        id: button6
        x: 786
        y: 364
        width: 150
        height: 100
        text: qsTr("Feet/Demist")
        checkable: true
        ButtonGroup.group: airflowModeGroup
    }

    Button {
        id: button9
        x: 8
        y: 17
        text: qsTr("ECO")
    }

    Button {
        id: button10
        x: 280
        y: 17
        text: qsTr("Normal Operation")
    }

    Button {
        id: button11
        x: 128
        y: 17
        text: qsTr("Ambient Mode")
    }

    Text {
        id: text1
        x: 898
        y: 212
        width: 98
        height: 29
        text: qsTr("Fan Speed")
        font.pixelSize: 20
    }

    Text {
        id: text2
        x: 275
        y: 212
        width: 121
        height: 29
        text: qsTr("Temperature")
        font.pixelSize: 20
    }

    Text {
        id: text3
        x: 580
        y: 558
        width: 121
        height: 29
        text: qsTr("Recirc/Fresh")
        font.pixelSize: 20
    }

    Switch {
        id: switch2
        x: 314
        y: 586
        width: 229
        height: 28
    }

    Text {
        id: text4
        x: 410
        y: 558
        width: 37
        height: 29
        text: qsTr("A/C")
        font.pixelSize: 20
    }

    Switch {
        id: switch3
        x: 100
        y: 586
        width: 229
        height: 28
    }

    Text {
        id: text5
        x: 189
        y: 558
        width: 51
        height: 29
        text: qsTr("AUTO")
        font.pixelSize: 20
    }

    Text {
        id: text6
        x: 809
        y: 555
        width: 121
        height: 29
        text: qsTr("Demist Rear")
        font.pixelSize: 20
    }

    Button {
        id: button12
        x: 1022
        y: 590
        checkable: true
    }

    Text {
        id: text7
        x: 1032
        y: 555
        width: 60
        height: 29
        text: qsTr("Power")
        font.pixelSize: 20
    }
}
