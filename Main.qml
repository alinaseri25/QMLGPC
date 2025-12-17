import QtQuick
import QtQuick.Controls.Basic
import QMLGPC

ApplicationWindow {
    id: root
    width: 800
    height: 600
    visible: true
    title: qsTr("QMLGPC")

    color: Theme.background

    // RTL Support
    LayoutMirroring.enabled: Theme.isRTL
    LayoutMirroring.childrenInherit: true

    Header {
        id: header
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        z: 10  // بالاتر از ScrollView

        onMenuClicked: {
            menuDrawer.open()
        }

        onSettingsClicked: {
            settingsDialog.open()
        }
    }

    // Main Content با ScrollView
    ScrollView {
        id: scrollView
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: header.bottom
        anchors.bottom: parent.bottom
        clip: true

        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        GpsPanel {
            width: scrollView.width
        }
    }

    // Menu Drawer
    Drawer {
        id: menuDrawer
        width: 250
        height: root.height
        edge: Theme.drawerEdge()

        background: Rectangle {
            color: Theme.surface
            border.color: Theme.border
            border.width: 1
        }

        contentItem: Item {
            anchors.fill: parent
            LayoutMirroring.enabled: Theme.isRTL
            LayoutMirroring.childrenInherit: true

            Column {
                anchors.fill: parent
                anchors.margins: Theme.spacing
                spacing: Theme.spacing

                Text {
                    width: parent.width
                    text: Theme.isRTL ? "منو" : "Menu"
                    font.pixelSize: 20
                    font.bold: true
                    color: Theme.text
                    horizontalAlignment: Theme.textAlignment()
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Theme.border
                }

                Button {
                    width: parent.width
                    text: Theme.isRTL ? "📍 داده‌های GPS" : "📍 GPS Data"
                    flat: true

                    background: Rectangle {
                        color: parent.hovered ? Theme.hoverColor : "transparent"
                        radius: Theme.radius
                    }

                    contentItem: Text {
                        text: parent.text
                        color: Theme.text
                        horizontalAlignment: Theme.textAlignment()
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 16
                        leftPadding: Theme.isRTL ? 0 : Theme.spacing
                        rightPadding: Theme.isRTL ? Theme.spacing : 0
                    }

                    onClicked: {
                        console.log("GPS Data clicked")
                        menuDrawer.close()
                    }
                }

                Button {
                    width: parent.width
                    text: Theme.isRTL ? "⚙ تنظیمات" : "⚙ Settings"
                    flat: true

                    background: Rectangle {
                        color: parent.hovered ? Theme.hoverColor : "transparent"
                        radius: Theme.radius
                    }

                    contentItem: Text {
                        text: parent.text
                        color: Theme.text
                        horizontalAlignment: Theme.textAlignment()
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 16
                        leftPadding: Theme.isRTL ? 0 : Theme.spacing
                        rightPadding: Theme.isRTL ? Theme.spacing : 0
                    }

                    onClicked: {
                        settingsDialog.open()
                        menuDrawer.close()
                    }
                }

                Button {
                    width: parent.width
                    text: Theme.isRTL ? "ℹ درباره" : "ℹ About"
                    flat: true

                    background: Rectangle {
                        color: parent.hovered ? Theme.hoverColor : "transparent"
                        radius: Theme.radius
                    }

                    contentItem: Text {
                        text: parent.text
                        color: Theme.text
                        horizontalAlignment: Theme.textAlignment()
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 16
                        leftPadding: Theme.isRTL ? 0 : Theme.spacing
                        rightPadding: Theme.isRTL ? Theme.spacing : 0
                    }

                    onClicked: {
                        console.log("About clicked")
                        menuDrawer.close()
                    }
                }
            }
        }
    }

    // Settings Dialog
    Dialog {
        id: settingsDialog
        title: Theme.isRTL ? "تنظیمات" : "Settings"
        anchors.centerIn: parent
        width: 400
        height: 300
        modal: true

        background: Rectangle {
            color: Theme.surface
            border.color: Theme.border
            border.width: 1
            radius: Theme.radius
        }

        header: Item {
            width: parent.width
            height: 50
            LayoutMirroring.enabled: Theme.isRTL
            LayoutMirroring.childrenInherit: true

            Rectangle {
                anchors.fill: parent
                color: Theme.surface

                Text {
                    anchors.centerIn: parent
                    text: Theme.isRTL ? "تنظیمات" : "Settings"
                    font.pixelSize: 18
                    font.bold: true
                    color: Theme.text
                }
            }
        }

        contentItem: Item {
            anchors.fill: parent
            LayoutMirroring.enabled: Theme.isRTL
            LayoutMirroring.childrenInherit: true

            Column {
                anchors.fill: parent
                spacing: Theme.spacingLarge
                padding: Theme.spacing

                Row {
                    spacing: Theme.spacing
                    width: parent.width - Theme.spacing * 2

                    Text {
                        text: Theme.isRTL ? "حالت شب:" : "Dark Mode:"
                        color: Theme.text
                        font.pixelSize: 16
                        anchors.verticalCenter: parent.verticalCenter
                        width: 150
                        horizontalAlignment: Theme.textAlignment()
                    }

                    Switch {
                        checked: Theme.isDarkMode
                        onToggled: Theme.isDarkMode = checked
                    }
                }

                Row {
                    spacing: Theme.spacing
                    width: parent.width - Theme.spacing * 2

                    Text {
                        text: Theme.isRTL ? "زبان راست به چپ:" : "RTL Language:"
                        color: Theme.text
                        font.pixelSize: 16
                        anchors.verticalCenter: parent.verticalCenter
                        width: 150
                        horizontalAlignment: Theme.textAlignment()
                    }

                    Switch {
                        checked: Theme.isRTL
                        onToggled: Theme.isRTL = checked
                    }
                }
            }
        }
    }
}
