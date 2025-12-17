import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    required property var theme

    color: theme.surface
    radius: theme.radius
    border.color: theme.border
    border.width: 1

    property var satellites: []

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // هدر
        Text {
            text: "ماهواره‌های دریافتی"
            font.pixelSize: 16
            font.bold: true
            color: theme.text
            Layout.fillWidth: true
            horizontalAlignment: theme.isRTL ? Text.AlignRight : Text.AlignLeft
        }

        // خط جداکننده
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: theme.border
        }

        // نمودار میله‌ای
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AsNeeded
            ScrollBar.vertical.policy: ScrollBar.AlwaysOff

            Flow {
                width: parent.width
                spacing: 12
                layoutDirection: theme.isRTL ? Qt.RightToLeft : Qt.LeftToRight

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
            visible: root.satellites.length === 0
            Layout.alignment: Qt.AlignCenter
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: "در انتظار دریافت اطلاعات ماهواره..."
            font.pixelSize: 14
            color: theme.textSecondary
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}
