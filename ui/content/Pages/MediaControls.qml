import QtQuick 6.8
import QtQuick.Controls 6.8

MediaControlsForm {
    id: root
    width: 1280
    height: 800

    function connectPresetButtons() {
        for (let i = 0; i < presetRepeater.count; ++i) {
            const item = presetRepeater.itemAt(i)
            if (!item || !item.presetButton || item._connected)
                continue

            item._connected = true

            item.presetButton.clicked.connect(function() {
                listView.currentIndex = i
            })
        }
    }

    Component.onCompleted: connectPresetButtons()

}
