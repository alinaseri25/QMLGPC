import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    required property var theme
    property string title: ""
    property string value: ""
    property string unit: ""
    property string icon: ""

    implicitWidth: 180
    implicitHeight: 120
    color: theme.cardBackground
    radius: theme.radius
    border.color: theme.cardBorder
    border.width: 1

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 8

        // ردیف بالا: آیکون + تایتل
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            layoutDirection: theme.isRTL ? Qt.RightToLeft : Qt.LeftToRight

            Text {
                text: root.icon
                font.pixelSize: 18
                color: theme.text
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                text: root.title
                font.pixelSize: 13
                color: theme.textSecondary
                Layout.fillWidth: true
                elide: Text.ElideRight
                horizontalAlignment: theme.isRTL ? Text.AlignRight : Text.AlignLeft
                Layout.alignment: Qt.AlignVCenter
            }
        }

        // فاصله انعطاف‌پذیر
        Item {
            Layout.fillHeight: true
            Layout.minimumHeight: 10
        }

        // ردیف پایین: مقدار + واحد
        RowLayout {
            Layout.fillWidth: true
            spacing: 6
            layoutDirection: theme.isRTL ? Qt.RightToLeft : Qt.LeftToRight

            Text {
                text: root.value
                font.pixelSize: 24
                font.bold: true
                color: theme.text
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                text: root.unit
                font.pixelSize: 13
                color: theme.textSecondary
                Layout.alignment: Qt.AlignVCenter
            }

            // فضای خالی برای چپ‌چین/راست‌چین
            Item {
                Layout.fillWidth: true
            }
        }
    }
}
