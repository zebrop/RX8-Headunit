import QtQuick 6.8
import QtQuick.Controls 6.8
import Rx8_HeadUnit

PerformanceForm {
    id: form
    width: 1280
    height: 800

    property var gateway: (typeof teensyGateway !== "undefined") ? teensyGateway : null

    function clamp(value, minValue, maxValue) {
        return Math.max(minValue, Math.min(maxValue, value))
    }

    function numberText(value, decimals, suffix, fallback) {
        if (!gateway || value === undefined || isNaN(value))
            return fallback || "--"
        return Number(value).toFixed(decimals) + (suffix || "")
    }

    rpmValueText.text: gateway ? Math.round(gateway.rpm).toString() : "0"

    coolantValueText.text: numberText(gateway ? gateway.coolantC : NaN, 0, "°c")
    batteryValueText.text: numberText(gateway ? gateway.batteryV : NaN, 1, "v")
    iatValueText.text: numberText(gateway ? gateway.iatC : NaN, 0, "°c")
    throttleValueText.text: numberText(gateway ? gateway.throttlePedalPercent : NaN, 0, "%")
    throttleFillItem.width: 240 * clamp((gateway ? gateway.throttlePedalPercent : 0) / 100, 0, 1)

    speedValueText.text: gateway ? Math.round(gateway.speedKmh).toString() : "0"

    fuelPercentText.text: numberText(gateway ? gateway.fuelLevelPercent : NaN, 0, "%")
    fuelFillItem.width: 157 * clamp((gateway ? gateway.fuelLevelPercent : 0) / 100, 0, 1)

    instantFuelValueText.text: gateway
                               ? (gateway.instantFuelMode === 1
                                  ? numberText(gateway.instantLph, 1, "")
                                  : numberText(gateway.instantL100km, 1, ""))
                               : "--"
    instantFuelUnitText.text: gateway && gateway.instantFuelMode === 1 ? "L/h" : "L/100km"
    averageFuelValueText.text: "--"

    afrValueText.text: numberText(gateway ? gateway.actualAfr : NaN, 1, "")
    mafValueText.text: numberText(gateway ? gateway.mafGps : NaN, 1, " g/s")

    WheelTelemetryOverlay {
        anchors.fill: parent
        vehicleGroup: form.vehicleGroupItem
        frontLeftWheel: form.frontLeftWheelItem
        frontRightWheel: form.frontRightWheelItem
        rearLeftWheel: form.rearLeftWheelItem
        rearRightWheel: form.rearRightWheelItem
        steeringDeg: gateway ? gateway.roadWheelEstDeg : 0
        frontLeftSpeedKmh: gateway ? gateway.wheelFlKmh : 0
        frontRightSpeedKmh: gateway ? gateway.wheelFrKmh : 0
        rearLeftSpeedKmh: gateway ? gateway.wheelRlKmh : 0
        rearRightSpeedKmh: gateway ? gateway.wheelRrKmh : 0
    }
}
