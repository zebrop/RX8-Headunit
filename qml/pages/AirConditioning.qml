import QtQuick 6.8

AirConditioningForm {
    id: root
    width: 1280
    height: 800

    readonly property url iconFace: Qt.resolvedUrl("../../assets/icons/Face.svg")
    readonly property url iconFeet: Qt.resolvedUrl("../../assets/icons/Feet.svg")
    readonly property url iconFaceFeet: Qt.resolvedUrl("../../assets/icons/Face_Feet.svg")
    readonly property url iconFeetDemist: Qt.resolvedUrl("../../assets/icons/Feet_Demist.svg")
    readonly property url iconDemist: Qt.resolvedUrl("../../assets/icons/Demist.svg")
    readonly property url iconRearDemist: Qt.resolvedUrl("../../assets/icons/Rear_Demist.svg")
    readonly property url iconRecirc: Qt.resolvedUrl("../../assets/icons/Recirc.svg")
    readonly property url iconFresh: Qt.resolvedUrl("../../assets/icons/Fresh.svg")
    readonly property url iconPower: Qt.resolvedUrl("../../assets/icons/Power.svg")
    readonly property url iconAuto: Qt.resolvedUrl("../../assets/icons/Auto.svg")
    readonly property url iconAC: Qt.resolvedUrl("../../assets/icons/AC.svg")

    readonly property int modeFace: 0
    readonly property int modeFaceFeet: 1
    readonly property int modeFeet: 2
    readonly property int modeFeetDemist: 3
    readonly property int modeDemist: 4

    property int lastSelectedMode: modeFace
    property bool lastRecircChecked: false
    property bool lastAutoChecked: false
    property bool lastAcChecked: false
    property bool lastRearDemistChecked: false

    property bool restoringPowerState: false

    faceButton.iconSource: iconFace
    feetButton.iconSource: iconFeet
    faceFeetButton.iconSource: iconFaceFeet
    feetDemistButton.iconSource: iconFeetDemist
    demistFrontButton.iconSource: iconDemist
    rearDemistButton.iconSource: iconRearDemist
    powerButton.iconSource: iconPower
    autoButton.iconSource: iconAuto
    acButton.iconSource: iconAC

    faceButton.iconSize: 76
    feetButton.iconSize: 76
    faceFeetButton.iconSize: 76
    feetDemistButton.iconSize: 76
    demistFrontButton.iconSize: 86
    rearDemistButton.iconSize: 56
    powerButton.iconSize: 70
    autoButton.iconSize: 60
    acButton.iconSize: 60

    recircSwitch.iconSource: recircSwitch.checked ? iconRecirc : iconFresh

    function fanSpeed() {
        return Math.round(fanSlider.value)
    }

    function isPowerOn() {
        return fanSpeed() > 0
    }

    function saveCurrentState() {
        lastAutoChecked = autoButton.checked
        lastAcChecked = acButton.checked
        lastRearDemistChecked = rearDemistButton.checked
        lastRecircChecked = recircSwitch.checked
    }

    function setAirflowMode(mode) {
        lastSelectedMode = mode

        faceButton.checked = mode === modeFace
        faceFeetButton.checked = mode === modeFaceFeet
        feetButton.checked = mode === modeFeet
        feetDemistButton.checked = mode === modeFeetDemist
        demistFrontButton.checked = mode === modeDemist
    }

    function clearAirflow() {
        faceButton.checked = false
        faceFeetButton.checked = false
        feetButton.checked = false
        feetDemistButton.checked = false
        demistFrontButton.checked = false
    }

    function applyPowerState() {
        var on = isPowerOn()

        powerButton.checked = on

        recircSwitch.enabled = on
        recircSwitch.glowEnabled = on
        recircSwitch.permanentGlow = on

        faceButton.enabled = on
        faceFeetButton.enabled = on
        feetButton.enabled = on
        feetDemistButton.enabled = on
        demistFrontButton.enabled = on

        autoButton.enabled = on
        acButton.enabled = on

        if (!on) {
            clearAirflow()
            autoButton.checked = false
            acButton.checked = false

            // Rear demist and recirc keep their visual state.
            return
        }

        setAirflowMode(lastSelectedMode)
        recircSwitch.checked = lastRecircChecked
        autoButton.checked = lastAutoChecked
        acButton.checked = lastAcChecked
        rearDemistButton.checked = lastRearDemistChecked
    }

    function powerOff() {
        saveCurrentState()

        fanSlider.value = 0
        applyPowerState()
    }

    function powerOn() {
        restoringPowerState = true

        if (fanSlider.value <= 0)
            fanSlider.value = 1

        applyPowerState()

        restoringPowerState = false
    }

    Component.onCompleted: {
        setAirflowMode(lastSelectedMode)

        lastRecircChecked = recircSwitch.checked
        lastAutoChecked = autoButton.checked
        lastAcChecked = acButton.checked
        lastRearDemistChecked = rearDemistButton.checked

        applyPowerState()
    }

    faceButton.onClicked: {
        if (isPowerOn())
            setAirflowMode(modeFace)
    }

    faceFeetButton.onClicked: {
        if (isPowerOn())
            setAirflowMode(modeFaceFeet)
    }

    feetButton.onClicked: {
        if (isPowerOn())
            setAirflowMode(modeFeet)
    }

    feetDemistButton.onClicked: {
        if (isPowerOn())
            setAirflowMode(modeFeetDemist)
    }

    demistFrontButton.onClicked: {
        if (isPowerOn())
            setAirflowMode(modeDemist)
    }

    powerButton.onClicked: {
        if (isPowerOn())
            powerOff()
        else
            powerOn()
    }

    temperatureSlider.onValueChangedByUser: (v) => {
        temperatureSlider.value = Math.round(v)
    }

    fanSlider.onValueChangedByUser: (v) => {
        var oldFan = fanSpeed()

        fanSlider.value = Math.round(v)

        if (fanSlider.value <= 0) {
            powerOff()
            return
        }

        if (oldFan > 0 && autoButton.checked && !restoringPowerState) {
            autoButton.checked = false
            lastAutoChecked = false
        }

        applyPowerState()
    }

    autoButton.onClicked: {
        if (!isPowerOn()) {
            autoButton.checked = false
            return
        }

        lastAutoChecked = autoButton.checked
    }

    acButton.onClicked: {
        if (!isPowerOn()) {
            acButton.checked = false
            return
        }

        lastAcChecked = acButton.checked
    }

    rearDemistButton.onClicked: {
        lastRearDemistChecked = rearDemistButton.checked
    }

    recircSwitch.onToggled: (v) => {
        if (!isPowerOn()) {
            return
        }

        lastRecircChecked = v
    }
}
