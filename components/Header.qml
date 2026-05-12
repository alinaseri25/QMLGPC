import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    required property var theme

    signal menuClicked()
    signal settingsClicked()

    width: parent.width
    height: theme.headerHeight
    color: theme.surface

    border.color: theme.border
    border.width: 1

    RowLayout {
        anchors.fill: parent
        anchors.margins: theme.spacing.md
        spacing: theme.spacing.md

        // دکمه منو
        Button {
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            text: "≡"
            flat: true

            background: Rectangle {
                color: parent.hovered ? theme.hoverColor : "transparent"
                radius: theme.radius.md
            }

            contentItem: Text {
                text: parent.text
                color: theme.textPrimary
                font.pixelSize: theme.fontSize.md
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: root.menuClicked()
        }

        // عنوان
        Text {
            Layout.fillWidth: true
            text: theme.isRTL ? "مدیریت GPS" : "GPS Manager"
            font.pixelSize: theme.fontSize.lg
            font.bold: true
            color: theme.textPrimary
            horizontalAlignment: theme.textAlignment()
        }

        // دکمه تنظیمات
        Button {
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            text: "⚙️"
            flat: true

            background: Rectangle {
                color: parent.hovered ? theme.hoverColor : "transparent"
                radius: theme.radius.md
            }

            contentItem: Text {
                text: parent.text
                color: theme.textPrimary
                font.pixelSize: 20
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: root.settingsClicked()
        }
    }
}
