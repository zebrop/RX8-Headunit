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

    baseUpButton.onClicked: {
        baseSlider.value = Math.min(baseSlider.to, baseSlider.value + baseSlider.stepSize)
    }

    baseDownButton.onClicked: {
        baseSlider.value = Math.max(baseSlider.from, baseSlider.value - baseSlider.stepSize)
    }

    midUpButton.onClicked: {
        midSlider.value = Math.min(midSlider.to, midSlider.value + midSlider.stepSize)
    }

    midDownButton.onClicked: {
        midSlider.value = Math.max(midSlider.from, midSlider.value - midSlider.stepSize)
    }

    trebleUpButton.onClicked: {
        trebleSlider.value = Math.min(trebleSlider.to, trebleSlider.value + trebleSlider.stepSize)
    }

    trebleDownButton.onClicked: {
        trebleSlider.value = Math.max(trebleSlider.from, trebleSlider.value - trebleSlider.stepSize)
    }

    volumeUpButton.onClicked: {
        volumeSlider.value = Math.min(volumeSlider.to, volumeSlider.value + volumeSlider.stepSize)
    }

    volumeDownButton.onClicked: {
        volumeSlider.value = Math.max(volumeSlider.from, volumeSlider.value - volumeSlider.stepSize)
    }
}
