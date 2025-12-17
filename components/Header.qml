import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QMLGPC

Rectangle {
    id: header
    height: 60
    color: Theme.surface

    signal menuClicked()
    signal settingsClicked()

    // RTL Support
    LayoutMirroring.enabled: Theme.isRTL
    LayoutMirroring.childrenInherit: true

    RowLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacing
        spacing: Theme.spacing

        // Menu Button
        Button {
            text: "☰"
            font.pixelSize: 24
            flat: true

            background: Rectangle {
                color: parent.hovered ? Theme.hoverColor : "transparent"
                radius: Theme.radius
            }

            contentItem: Text {
                text: parent.text
                color: Theme.text
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font: parent.font
            }

            onClicked: header.menuClicked()
        }

        // Title
        Text {
            text: "QMLGPC"
            font.pixelSize: 20
            font.bold: true
            color: Theme.text
            Layout.fillWidth: true
            horizontalAlignment: Theme.textAlignment()
        }

        // Theme Toggle Button
        Button {
            text: Theme.isDarkMode ? "☀" : "🌙"
            font.pixelSize: 20
            flat: true

            background: Rectangle {
                color: parent.hovered ? Theme.hoverColor : "transparent"
                radius: Theme.radius
            }

            contentItem: Text {
                text: parent.text
                color: Theme.text
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font: parent.font
            }

            onClicked: Theme.isDarkMode = !Theme.isDarkMode
        }

        // Settings Button
        Button {
            text: "⚙"
            font.pixelSize: 20
            flat: true

            background: Rectangle {
                color: parent.hovered ? Theme.hoverColor : "transparent"
                radius: Theme.radius
            }

            contentItem: Text {
                text: parent.text
                color: Theme.text
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font: parent.font
            }

            onClicked: header.settingsClicked()
        }
    }
}
