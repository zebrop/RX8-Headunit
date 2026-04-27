import QtQuick 6.8
import QtQuick.Controls 6.8
import QtCore as QtCore
import "../data/MediaPresets.js" as MediaPresets

MediaControlsForm {
    id: root

    width: 1280
    height: 800

    property bool isLoadingState: true
    property bool isApplyingPreset: false

    property url interiorSource: Qt.resolvedUrl("../../assets/car/interior.png")

    QtCore.Settings {
        id: mediaSettings
        category: "MediaControls"

        property string selectedPresetName: "Flat"
        property string userPresetsJson: "[]"
        property string customPresetJson: "{\"name\":\"Custom\",\"bass\":0,\"mid\":0,\"treble\":0,\"deletable\":false}"

        property real bass: 0
        property real mid: 0
        property real treble: 0
        property real volume: 15

        property real xyX: 0
        property real xyY: 0

        property string hiddenDefaultPresetNamesJson: "[]"
    }

    Timer {
        id: saveDebounceTimer
        interval: 120
        repeat: false
        onTriggered: saveCurrentStateImmediate()
    }

    function scheduleSave() {
        if (isLoadingState)
            return

        saveDebounceTimer.restart()
    }

    function safeNumber(value, fallback) {
        const n = Number(value)
        return isNaN(n) ? fallback : n
    }

    function normalizedPreset(preset, fallbackName, deletable) {
        return {
            "name": String(preset.name || fallbackName),
            "bass": safeNumber(preset.bass, 0),
            "mid": safeNumber(preset.mid, 0),
            "treble": safeNumber(preset.treble, 0),
            "deletable": deletable
        }
    }

    function loadDefaultPresets() {
        return MediaPresets.defaultPresets().map(function(p, i) {
            return normalizedPreset(p, "Preset " + (i + 1), false)
        })
    }

    function loadJsonArray(text) {
        try {
            const parsed = JSON.parse(text)
            if (parsed && parsed.length >= 0)
                return parsed
        } catch (e) {
        }

        return []
    }

    function hiddenDefaultPresetNames() {
        try {
            const parsed = JSON.parse(mediaSettings.hiddenDefaultPresetNamesJson)
            return parsed || []
        } catch (e) {
            return []
        }
    }

    function saveHiddenDefaultPresetNames(names) {
        mediaSettings.hiddenDefaultPresetNamesJson = JSON.stringify(names)
    }

    function loadCustomPreset() {
        try {
            return normalizedPreset(JSON.parse(mediaSettings.customPresetJson), customPresetName, false)
        } catch (e) {
            return {
                "name": customPresetName,
                "bass": mediaSettings.bass,
                "mid": mediaSettings.mid,
                "treble": mediaSettings.treble,
                "deletable": false
            }
        }
    }

    function rebuildPresetModel() {
        const hiddenNames = hiddenDefaultPresetNames()

        const defaults = loadDefaultPresets().filter(function(p) {
            return hiddenNames.indexOf(p.name) === -1
        })

        const userPresets = loadJsonArray(mediaSettings.userPresetsJson).map(function(p, i) {
            return normalizedPreset(p, "User Preset " + (i + 1), true)
        })

        const custom = loadCustomPreset()
        custom.name = customPresetName
        custom.deletable = false

        presetModel = defaults.concat(userPresets).concat([custom])
    }

    function findPresetIndex(name) {
        for (let i = 0; i < presetModel.length; ++i) {
            if (presetModel[i].name === name)
                return i
        }

        return -1
    }

    function customPresetIndex() {
        return findPresetIndex(customPresetName)
    }

    function currentPreset() {
        if (currentPresetIndex < 0 || currentPresetIndex >= presetModel.length)
            return null

        return presetModel[currentPresetIndex]
    }

    function setEqualizerValues(bass, mid, treble) {
        isApplyingPreset = true

        equalizer.bassValue = bass
        equalizer.midValue = mid
        equalizer.trebleValue = treble

        equalizer.bassVisualValue = bass
        equalizer.midVisualValue = mid
        equalizer.trebleVisualValue = treble
        equalizer.requestCurvePaint()

        isApplyingPreset = false
    }

    function selectPreset(index, applyEq) {
        if (index < 0 || index >= presetModel.length)
            return

        currentPresetIndex = index

        if (applyEq) {
            const preset = presetModel[index]
            setEqualizerValues(preset.bass, preset.mid, preset.treble)
        }

        scheduleSave()
    }

    function makeUniquePresetName(baseName) {
        let cleanName = String(baseName).trim()

        if (cleanName.length === 0)
            cleanName = "Preset"

        if (cleanName === customPresetName)
            cleanName = "Preset"

        let candidate = cleanName
        let suffix = 2

        while (findPresetIndex(candidate) !== -1) {
            candidate = cleanName + " " + suffix
            ++suffix
        }

        return candidate
    }

    function userPresetsOnly() {
        const result = []

        for (let i = 0; i < presetModel.length; ++i) {
            const preset = presetModel[i]
            if (preset.deletable === true) {
                result.push({
                    "name": preset.name,
                    "bass": preset.bass,
                    "mid": preset.mid,
                    "treble": preset.treble,
                    "deletable": true
                })
            }
        }

        return result
    }

    function saveCustomPreset() {
        const idx = customPresetIndex()
        if (idx < 0)
            return

        const preset = presetModel[idx]
        mediaSettings.customPresetJson = JSON.stringify({
            "name": customPresetName,
            "bass": preset.bass,
            "mid": preset.mid,
            "treble": preset.treble,
            "deletable": false
        })
    }

    function saveCurrentStateImmediate() {
        if (isLoadingState)
            return

        mediaSettings.bass = equalizer.bassValue
        mediaSettings.mid = equalizer.midValue
        mediaSettings.treble = equalizer.trebleValue
        mediaSettings.volume = volumeSlider.value

        mediaSettings.xyX = xyPad.xValue
        mediaSettings.xyY = xyPad.yValue

        const selected = currentPreset()
        if (selected)
            mediaSettings.selectedPresetName = selected.name

        mediaSettings.userPresetsJson = JSON.stringify(userPresetsOnly())
        saveCustomPreset()
    }

    function selectCustomFromManualEqChange() {
        if (isLoadingState || isApplyingPreset)
            return

        const idx = customPresetIndex()
        if (idx < 0)
            return

        // Mutate in-place — no array reassignment, so ListView never rebuilds its delegates
        presetModel[idx].bass = equalizer.bassValue
        presetModel[idx].mid = equalizer.midValue
        presetModel[idx].treble = equalizer.trebleValue

        currentPresetIndex = idx
        scheduleSave()
    }

    function addCurrentPreset(name) {
        const finalName = makeUniquePresetName(name)
        const customIdx = customPresetIndex()
        const insertIndex = customIdx >= 0 ? customIdx : presetModel.length

        const copy = presetModel.slice()
        copy.splice(insertIndex, 0, {
            "name": finalName,
            "bass": equalizer.bassValue,
            "mid": equalizer.midValue,
            "treble": equalizer.trebleValue,
            "deletable": true
        })

        presetModel = copy
        selectPreset(insertIndex, false)
        saveCurrentStateImmediate()
    }

    function deletePreset(index) {
        if (index < 0 || index >= presetModel.length)
            return

        const preset = presetModel[index]

        if (preset.name === customPresetName)
            return

        if (preset.deletable !== true) {
            const hiddenNames = hiddenDefaultPresetNames()

            if (hiddenNames.indexOf(preset.name) === -1) {
                hiddenNames.push(preset.name)
                saveHiddenDefaultPresetNames(hiddenNames)
            }
        }

        const wasSelected = index === currentPresetIndex
        const copy = presetModel.slice()
        copy.splice(index, 1)
        presetModel = copy

        if (wasSelected) {
            const customIdx = customPresetIndex()
            currentPresetIndex = customIdx >= 0 ? customIdx : 0
        } else if (currentPresetIndex > index) {
            currentPresetIndex -= 1
        }

        saveCurrentStateImmediate()
    }

    function loadState() {
        isLoadingState = true

        rebuildPresetModel()

        setEqualizerValues(mediaSettings.bass, mediaSettings.mid, mediaSettings.treble)

        volumeSlider.value = mediaSettings.volume
        xyPad.xValue = mediaSettings.xyX
        xyPad.yValue = mediaSettings.xyY

        let selectedIndex = findPresetIndex(mediaSettings.selectedPresetName)

        if (selectedIndex < 0)
            selectedIndex = customPresetIndex()

        if (selectedIndex < 0)
            selectedIndex = 0

        currentPresetIndex = selectedIndex

        isLoadingState = false
        saveCurrentStateImmediate()
    }

    Connections {
        target: presetBox

        function onPresetClicked(index) {
            selectPreset(index, true)
        }

        function onDeleteRequested(index) {
            deletePreset(index)
        }

        function onAddRequested() {
            addPresetPopup.openForNewPreset()
        }
    }

    Connections {
        target: addPresetPopup

        function onAccepted(name) {
            addCurrentPreset(name)
        }
    }

    Connections {
        target: equalizer

        function onBassChangedByUser(value) {
            selectCustomFromManualEqChange()
        }

        function onMidChangedByUser(value) {
            selectCustomFromManualEqChange()
        }

        function onTrebleChangedByUser(value) {
            selectCustomFromManualEqChange()
        }
    }

    Connections {
        target: volumeSlider

        function onValueChanged() {
            scheduleSave()
        }
    }

    Connections {
        target: xyPad

        function onXValueChanged() {
            scheduleSave()
        }

        function onYValueChanged() {
            scheduleSave()
        }
    }

    Component.onCompleted: loadState()
}
