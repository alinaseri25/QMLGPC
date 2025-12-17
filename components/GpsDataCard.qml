import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QMLGPC

Rectangle {
    id: root

    required property string icon
    required property string title
    required property string value
    property string unit: ""

    implicitWidth: 140
    implicitHeight: 100
    radius: 12
    color: Theme.cardBackground
    border.color: Theme.cardBorder
    border.width: 1

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        // Icon
        Text {
            text: root.icon
            font.pixelSize: 24
            color: Theme.primary
            Layout.alignment: Qt.AlignHCenter
        }

        // Title
        Text {
            text: root.title
            font.pixelSize: 11
            color: Theme.textSecondary
            Layout.alignment: Qt.AlignHCenter
            elide: Text.ElideRight
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
        }

        // Value
        RowLayout {
            spacing: 2
            Layout.alignment: Qt.AlignHCenter

            Text {
                text: root.value
                font.pixelSize: 18
                font.bold: true
                color: Theme.textPrimary
            }

            Text {
                text: root.unit
                font.pixelSize: 11
                color: Theme.textSecondary
                visible: root.unit !== ""
            }
        }
    }
}
