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
        anchors.margins: 12
        spacing: 8

        // ردیف بالا: آیکون + تایتل (وسط‌چین)
        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: 4

            Text {
                text: root.icon
                font.pixelSize: 20
                color: theme.text
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: root.title
                font.pixelSize: 12
                color: theme.textSecondary
                Layout.fillWidth: true
                Layout.maximumWidth: root.width - 24
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                maximumLineCount: 2
                elide: Text.ElideRight
            }
        }

        // فاصله انعطاف‌پذیر
        Item {
            Layout.fillHeight: true
            Layout.minimumHeight: 8
        }

        // ردیف پایین: مقدار + واحد (وسط‌چین)
        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: 4

            Text {
                text: root.value
                font.pixelSize: 22
                font.bold: true
                color: theme.text
                Layout.alignment: Qt.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                text: root.unit
                font.pixelSize: 11
                color: theme.textSecondary
                Layout.alignment: Qt.AlignVCenter
                wrapMode: Text.NoWrap
            }
        }
    }
}
