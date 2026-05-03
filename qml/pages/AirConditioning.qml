import QtQuick 6.8

AirConditioningForm {
    id: root
    width: 1280
    height: 800

    readonly property url iconFace: "qrc:/qt/qml/content/assets/icons/Face.svg"
    readonly property url iconFeet: "qrc:/qt/qml/content/assets/icons/Feet.svg"
    readonly property url iconFaceFeet: "qrc:/qt/qml/content/assets/icons/Face_Feet.svg"
    readonly property url iconFeetDemist: "qrc:/qt/qml/content/assets/icons/Feet_Demist.svg"
    readonly property url iconDemist: "qrc:/qt/qml/content/assets/icons/Demist.svg"
    readonly property url iconRearDemist: "qrc:/qt/qml/content/assets/icons/Rear_Demist.svg"
    readonly property url iconRecirc: "qrc:/qt/qml/content/assets/icons/Recirc.svg"
    readonly property url iconFresh: "qrc:/qt/qml/content/assets/icons/Fresh.svg"
    readonly property url iconPower: "qrc:/qt/qml/content/assets/icons/Power.svg"
    readonly property url iconAuto: "qrc:/qt/qml/content/assets/icons/Auto.svg"
    readonly property url iconAC: "qrc:/qt/qml/content/assets/icons/AC.svg"

    // Teensy ac_mode mapping:
    // 0 = unknown, 1 = feet, 2 = feet + demist, 3 = face, 4 = face + feet, 5 = front demist
    readonly property int modeUnknown: 0
    readonly property int modeFeet: 1
    readonly property int modeFeetDemist: 2
    readonly property int modeFace: 3
    readonly property int modeFaceFeet: 4
    readonly property int modeDemist: 5

    // Teensy ac_air_source mapping: 0 = recirc, 1 = fresh
    property var gateway: (typeof teensyGateway !== "undefined") ? teensyGateway : null
    readonly property bool acOnline: gateway && gateway.acRxValid
    readonly property bool acPowerOn: acOnline && gateway.acFan > 0

    faceButton.iconSource: iconFace
    feetButton.iconSource: iconFeet
    faceFeetButton.iconSource: iconFaceFeet
    feetDemistButton.iconSource: iconFeetDemist
    demistFrontButton.iconSource: iconDemist
    rearDemistButton.iconSource: iconRearDemist
    powerButton.iconSource: iconPower
    autoButton.iconSource: iconAuto
    acButton.iconSource: iconAC

    faceButton.checkable: false
    feetButton.checkable: false
    faceFeetButton.checkable: false
    feetDemistButton.checkable: false
    demistFrontButton.checkable: false
    rearDemistButton.checkable: false
    powerButton.checkable: false
    autoButton.checkable: false
    acButton.checkable: false

    faceButton.iconSize: 76
    feetButton.iconSize: 76
    faceFeetButton.iconSize: 76
    feetDemistButton.iconSize: 76
    demistFrontButton.iconSize: 86
    rearDemistButton.iconSize: 56
    powerButton.iconSize: 70
    autoButton.iconSize: 60
    acButton.iconSize: 60

    temperatureSlider.enabled: acOnline
    fanSlider.enabled: acOnline
    recircSwitch.enabled: acPowerOn
    faceButton.enabled: acPowerOn
    faceFeetButton.enabled: acPowerOn
    feetButton.enabled: acPowerOn
    feetDemistButton.enabled: acPowerOn
    demistFrontButton.enabled: acPowerOn
    autoButton.enabled: acPowerOn
    acButton.enabled: acPowerOn
    rearDemistButton.enabled: acOnline

    recircSwitch.iconSource: recircSwitch.checked ? iconRecirc : iconFresh

    normalIndicator.color: acOnline && gateway.acRunning && !gateway.acEco ? Theme.accent : "#333332"
    ambientIndicator.color: acOnline && gateway.acAmbient ? Theme.accent : "#333332"
    ecoIndicator.color: acOnline && gateway.acEco ? Theme.accent : "#333332"

    Binding { target: temperatureSlider; property: "value"; value: gateway ? gateway.acTemp : 22 }
    Binding { target: fanSlider; property: "value"; value: gateway ? gateway.acFan : 0 }

    Binding { target: powerButton; property: "checked"; value: acPowerOn }
    Binding { target: autoButton; property: "checked"; value: acOnline && gateway.acAuto }
    Binding { target: acButton; property: "checked"; value: acOnline && gateway.acCompressor }
    Binding { target: rearDemistButton; property: "checked"; value: acOnline && gateway.acRearDemist }
    Binding { target: recircSwitch; property: "checked"; value: acOnline && gateway.acAirSource === 0 }

    Binding { target: faceButton; property: "checked"; value: acOnline && gateway.acMode === modeFace }
    Binding { target: faceFeetButton; property: "checked"; value: acOnline && gateway.acMode === modeFaceFeet }
    Binding { target: feetButton; property: "checked"; value: acOnline && gateway.acMode === modeFeet }
    Binding { target: feetDemistButton; property: "checked"; value: acOnline && gateway.acMode === modeFeetDemist }
    Binding { target: demistFrontButton; property: "checked"; value: acOnline && gateway.acMode === modeDemist }

    function send(command) {
        if (gateway)
            gateway.sendCommand(command)
    }

    function sendRepeated(command, count) {
        count = Math.max(0, Math.min(10, Math.round(count)))
        for (var i = 0; i < count; ++i)
            send(command)
    }

    faceButton.onClicked: send("face")
    faceFeetButton.onClicked: send("facefeet")
    feetButton.onClicked: send("feet")
    feetDemistButton.onClicked: send("feetdemist")
    demistFrontButton.onClicked: send("demist")
    autoButton.onClicked: send("auto")
    acButton.onClicked: send("ac")
    rearDemistButton.onClicked: send("reardemist")
    recircSwitch.onToggled: send("airsource")

    powerButton.onClicked: {
        if (acPowerOn)
            send("off")
        else
            send("fanup")
    }

    temperatureSlider.onValueChangedByUser: (v) => {
        if (!acOnline)
            return

        var target = Math.round(v)
        var current = Math.round(gateway.acTemp)
        if (target > current)
            sendRepeated("tempup", target - current)
        else if (target < current)
            sendRepeated("tempdown", current - target)
    }

    fanSlider.onValueChangedByUser: (v) => {
        if (!acOnline)
            return

        var target = Math.round(v)
        var current = Math.round(gateway.acFan)
        if (target > current)
            sendRepeated("fanup", target - current)
        else if (target < current)
            sendRepeated("fandown", current - target)
    }
}
