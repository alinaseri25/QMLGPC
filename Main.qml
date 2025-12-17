import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import "components"
import "panels"
import "theme"

ApplicationWindow {
    id: window
    visible: true
    width: 400
    height: 800
    title: appTheme.isRTL ? "مدیریت GPS پیشرفته" : "Advanced GPS Manager"

    Theme {
        id: appTheme
    }

    // فعال‌سازی RTL برای کل برنامه
    LayoutMirroring.enabled: appTheme.isRTL
    LayoutMirroring.childrenInherit: true

    background: Rectangle {
        color: appTheme.background
    }

    header: Header {
        theme: appTheme
        onMenuClicked: menuDrawer.open()
        onSettingsClicked: settingsDialog.open()
    }

    // محتوای اصلی
    ScrollView {
        anchors.fill: parent
        clip: true

        GpsPanel {
            theme: appTheme
            width: parent.width
        }
    }

    // منوی کشویی
    Drawer {
        id: menuDrawer
        width: Math.min(window.width * 0.7, 300)
        height: window.height
        edge: appTheme.drawerEdge()

        background: Rectangle {
            color: appTheme.surface
            border.color: appTheme.border
            border.width: 1
        }

        Column {
            anchors.fill: parent
            spacing: 0

            // هدر منو
            Rectangle {
                width: parent.width
                height: 120
                color: appTheme.primary

                Column {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        text: "🛰️"
                        font.pixelSize: 48
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: appTheme.isRTL ? "مدیریت GPS" : "GPS Manager"
                        font.pixelSize: 20
                        font.bold: true
                        color: "white"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: appTheme.border
            }

            // دکمه داده‌های GPS
            Button {
                width: parent.width
                text: appTheme.isRTL ? "📍 داده‌های GPS" : "📍 GPS Data"
                flat: true
                height: 50

                background: Rectangle {
                    color: parent.hovered ? appTheme.hoverColor : "transparent"
                    radius: 0
                }

                contentItem: Text {
                    text: parent.text
                    color: appTheme.text
                    horizontalAlignment: appTheme.textAlignment()
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 16
                    leftPadding: appTheme.isRTL ? 0 : appTheme.spacing
                    rightPadding: appTheme.isRTL ? appTheme.spacing : 0
                }

                onClicked: {
                    console.log("GPS Data clicked")
                    menuDrawer.close()
                }
            }

            // دکمه تنظیمات
            Button {
                width: parent.width
                text: appTheme.isRTL ? "⚙️ تنظیمات" : "⚙️ Settings"
                flat: true
                height: 50

                background: Rectangle {
                    color: parent.hovered ? appTheme.hoverColor : "transparent"
                    radius: 0
                }

                contentItem: Text {
                    text: parent.text
                    color: appTheme.text
                    horizontalAlignment: appTheme.textAlignment()
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 16
                    leftPadding: appTheme.isRTL ? 0 : appTheme.spacing
                    rightPadding: appTheme.isRTL ? appTheme.spacing : 0
                }

                onClicked: {
                    settingsDialog.open()
                    menuDrawer.close()
                }
            }

            // دکمه درباره
            Button {
                width: parent.width
                text: appTheme.isRTL ? "ℹ️ درباره" : "ℹ️ About"
                flat: true
                height: 50

                background: Rectangle {
                    color: parent.hovered ? appTheme.hoverColor : "transparent"
                    radius: 0
                }

                contentItem: Text {
                    text: parent.text
                    color: appTheme.text
                    horizontalAlignment: appTheme.textAlignment()
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 16
                    leftPadding: appTheme.isRTL ? 0 : appTheme.spacing
                    rightPadding: appTheme.isRTL ? appTheme.spacing : 0
                }

                onClicked: {
                    aboutDialog.open()
                    menuDrawer.close()
                }
            }
        }
    }

    // دیالوگ تنظیمات
    Dialog {
        id: settingsDialog
        title: "تنظیمات"
        modal: true
        anchors.centerIn: parent
        width: Math.min(parent.width * 0.8, 400)

        ColumnLayout {
            anchors.fill: parent
            spacing: 20

            // Dark Mode
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Text {
                    text: "حالت تاریک"
                    font.pixelSize: 14
                    color: appTheme.text
                    Layout.fillWidth: true
                }

                Switch {
                    id: darkModeSwitch
                    checked: appTheme.isDarkMode
                    onCheckedChanged: appTheme.isDarkMode = checked
                }
            }

            // RTL Mode
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Text {
                    text: "راست به چپ (RTL)"
                    font.pixelSize: 14
                    color: appTheme.text
                    Layout.fillWidth: true
                }

                Switch {
                    id: rtlSwitch
                    checked: appTheme.isRTL
                    onCheckedChanged: appTheme.isRTL = checked
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: appTheme.border
            }

            // Mock GPS Mode (جدید)
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Text {
                    text: "حالت تست GPS (بدون ماهواره واقعی)"
                    font.pixelSize: 14
                    color: appTheme.text
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                }

                Switch {
                    id: mockGpsSwitch
                    checked: gpsManager.useMockData
                    onCheckedChanged: {
                        gpsManager.useMockData = checked
                        // اگر GPS فعاله، restart کن
                        if (gpsManager.isValid) {
                            gpsManager.stopUpdates()
                            gpsManager.startUpdates()
                        }
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                text: "⚠️ این حالت فقط برای تست در محیط‌هایی که GPS ندارند استفاده شود"
                font.pixelSize: 11
                color: appTheme.accentOrange
                wrapMode: Text.WordWrap
                visible: mockGpsSwitch.checked
            }
        }

        standardButtons: Dialog.Close
    }

    // دیالوگ درباره
    Dialog {
        id: aboutDialog
        title: appTheme.isRTL ? "درباره" : "About"
        anchors.centerIn: parent
        width: Math.min(window.width * 0.9, 350)
        modal: true

        background: Rectangle {
            color: appTheme.surface
            border.color: appTheme.border
            border.width: 1
            radius: appTheme.radius
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: appTheme.spacingMedium

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "🛰️"
                font.pixelSize: 64
            }

            Text {
                Layout.fillWidth: true
                text: appTheme.isRTL ? "مدیریت GPS پیشرفته" : "Advanced GPS Manager"
                font.pixelSize: 20
                font.bold: true
                color: appTheme.text
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                Layout.fillWidth: true
                text: "Version 1.0.0"
                font.pixelSize: 14
                color: appTheme.textSecondary
                horizontalAlignment: Text.AlignHCenter
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: appTheme.border
            }

            Text {
                Layout.fillWidth: true
                text: appTheme.isRTL
                    ? "یک برنامه قدرتمند برای مدیریت و نمایش داده‌های GPS"
                    : "A powerful application for GPS data management and visualization"
                font.pixelSize: 14
                color: appTheme.textSecondary
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }

            Button {
                Layout.fillWidth: true
                Layout.topMargin: appTheme.spacing
                text: appTheme.isRTL ? "بستن" : "Close"

                background: Rectangle {
                    color: parent.pressed ? Qt.darker(appTheme.primary, 1.2) : (parent.hovered ? Qt.lighter(appTheme.primary, 1.1) : appTheme.primary)
                    radius: appTheme.radius
                }

                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: aboutDialog.close()
            }
        }
    }
}
