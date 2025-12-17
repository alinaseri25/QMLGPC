import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    required property var theme

    property string title: ""
    property string value: "---"
    property string unit: ""
    property string icon: "📍"

    implicitHeight: 100
    implicitWidth: 150

    color: theme.cardBackground
    radius: theme.cardRadius
    border.color: theme.cardBorder
    border.width: 1

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: theme.cardPadding
        spacing: theme.spacingSmall

        // آیکون
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: root.icon
            font.pixelSize: 32
        }

        // عنوان
        Text {
            Layout.fillWidth: true
            text: root.title
            font.pixelSize: theme.fontSizeSmall
            color: theme.textSecondary
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }

        // مقدار + واحد
        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: 4

            Text {
                text: root.value
                font.pixelSize: theme.fontSizeLarge
                font.bold: true
                color: theme.textPrimary
            }

            Text {
                text: root.unit
                font.pixelSize: theme.fontSizeMedium
                color: theme.textSecondary
            }
        }
    }
}
