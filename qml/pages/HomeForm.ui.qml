
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
    id: root
    width: Constants.width
    height: Constants.height
    color: Theme.backgroundColor

    // Expose for Home.qml to anchor the View3D behind the 2D chrome
    property alias view3DContainerItem: view3DContainer

    Image {
        id: pageBackground
        anchors.fill: parent
        source: Theme.homePageBackground
        fillMode: Image.PreserveAspectCrop
        smooth: true
        asynchronous: true
        visible: status === Image.Ready
    }

    // Dark gradient overlay so text and model read clearly
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "#cc000000" }
            GradientStop { position: 0.45; color: "#44000000" }
            GradientStop { position: 1.0; color: "#00000000" }
        }
    }

    // Placeholder item where Home.qml inserts the View3D
    Item {
        id: view3DContainer
        anchors.fill: parent
    }

    // ── Car identity ──────────────────────────────────────────────────────────
    Column {
        x: 52
        y: 220
        spacing: 6

        Text {
            text: "MAZDA"
            color: Theme.accent
            font.pixelSize: 18
            font.bold: true
            font.letterSpacing: 6
            font.family: Constants.font.family
        }

        Text {
            text: "RX-8"
            color: Theme.textPrimary
            font.pixelSize: 72
            font.bold: true
            font.letterSpacing: 2
        }

        Text {
            text: "Rotary Sports Coupe"
            color: Theme.textSecondary
            font.pixelSize: 16
            font.letterSpacing: 3
            font.family: Constants.font.family
        }
    }

    // Accent divider
    Rectangle {
        x: 52
        y: 430
        width: 220
        height: 2
        color: Theme.accent
        opacity: 0.6
    }

    // Drag hint
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height - 52
        text: "Drag to rotate"
        color: "#66ffffff"
        font.pixelSize: 13
        font.letterSpacing: 2
        font.family: Constants.font.family
    }
}
