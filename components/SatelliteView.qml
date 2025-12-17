import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QMLGPC
import "../components"

Rectangle {
    id: root
    required property var theme

    color: theme.surface
    radius: theme.radius
    border.color: theme.border
    border.width: 1

    property var satellites: []

    Column {
        anchors.fill: parent
        anchors.margins: theme.cardPadding
        spacing: theme.spacingMedium

        // هدر
        Text {
            width: parent.width  // ✨ حذف anchors.centerIn
            text: "ماهواره‌های دریافتی"
            font.pixelSize: theme.fontSizeLarge
            font.bold: true
            color: theme.text
            horizontalAlignment: Text.AlignHCenter
        }

        // نمودار میله‌ای
        ScrollView {
            width: parent.width
            height: parent.height - 40
            clip: true

            Flow {
                width: parent.width
                spacing: theme.spacingSmall

                Repeater {
                    model: root.satellites

                    SatelliteBar {
                        theme: root.theme
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
            width: parent.width  // ✨ به جای anchors.horizontalCenter
            visible: root.satellites.length === 0
            text: "در انتظار دریافت اطلاعات ماهواره..."
            font.pixelSize: theme.fontSizeMedium
            color: theme.textSecondary
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
