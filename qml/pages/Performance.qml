import QtQuick 6.8
import QtQuick.Controls 6.8
import Rx8_HeadUnit
import "../components"

PerformanceForm {
    id: form
    width: 1280
    height: 800

    WheelTelemetryOverlay {
        anchors.fill: parent
        vehicleGroup: form.vehicleGroupItem
        frontLeftWheel: form.frontLeftWheelItem
        frontRightWheel: form.frontRightWheelItem
        rearLeftWheel: form.rearLeftWheelItem
        rearRightWheel: form.rearRightWheelItem
    }
}
