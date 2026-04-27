

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

    color: Theme.backgroundColor

    Image {
        id: pageBackground
        anchors.fill: parent
        source: Theme.settingsPageBackground
        fillMode: Image.PreserveAspectCrop
        smooth: true
        asynchronous: true
        visible: status === Image.Ready
    }

    Text {
        text: qsTr("Settings Page")
        anchors.centerIn: parent
        font.family: Constants.font.family
        color: Theme.textPrimary
    }
}
