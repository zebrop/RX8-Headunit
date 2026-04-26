import QtQuick 6.8

AirConditioningForm {
    id: root
    width: 1280
    height: 800

    function clearAirflow() {
        faceButton.checked = false
        faceFeetButton.checked = false
        feetButton.checked = false
        feetDemistButton.checked = false
        demistFrontButton.checked = false
    }

    faceButton.onClicked: {
        clearAirflow()
        faceButton.checked = true
    }

    faceFeetButton.onClicked: {
        clearAirflow()
        faceFeetButton.checked = true
    }

    feetButton.onClicked: {
        clearAirflow()
        feetButton.checked = true
    }

    feetDemistButton.onClicked: {
        clearAirflow()
        feetDemistButton.checked = true
    }

    demistFrontButton.onClicked: {
        clearAirflow()
        demistFrontButton.checked = true
    }

    temperatureSlider.onValueChangedByUser: (v) => {
        console.log("Temp:", v)
    }

    fanSlider.onValueChangedByUser: (v) => {
        console.log("Fan:", v)
    }

    autoButton.onClicked: {
        clearAirflow()
        faceButton.checked = true
    }

    acButton.onClicked: {
        clearAirflow()
        faceButton.checked = true
    }

    recircSwitch.onToggled: (v) => console.log("Recirc:", v)
}
