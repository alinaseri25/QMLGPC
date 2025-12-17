import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QMLGPC

Rectangle {
    id: root
    color: Theme.surfaceColor
    radius: 12
    border.color: Theme.borderColor
    border.width: 1

    property var satellites: []

    Column {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // هدر
        Text {
            text: "ماهواره‌های دریافتی"
            font.pixelSize: 16
            font.bold: true
            color: Theme.primaryTextColor
        }

        // نمودار میله‌ای
        ScrollView {
            width: parent.width
            height: parent.height - 40
            clip: true

            Flow {
                width: parent.width
                spacing: 8

                Repeater {
                    model: root.satellites

                    SatelliteBar {
                        satelliteId: modelData.id || 0
                        signalStrength: modelData.signalStrength || 0
                        systemType: modelData.system || 0
                        inUse: modelData.inUse || false
                    }
                }
            }
        }

        // پیام خالی
        Text {
            visible: root.satellites.length === 0
            anchors.centerIn: parent
            text: "در انتظار دریافت اطلاعات ماهواره..."
            font.pixelSize: 14
            color: Theme.secondaryTextColor
        }
    }
}
