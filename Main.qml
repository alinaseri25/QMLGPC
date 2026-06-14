import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import "components"
import "panels"
import "theme"
import "pages"

ApplicationWindow {
    id: window
    visible: true
    width: 400
    height: 800

    function tr(fa, en) {
        return appTheme.isRTL ? fa : en
    }

    title: tr("مدیریت GPS پیشرفته", "Advanced GPS Manager")

    signal qmlLoaded()

    Theme {
        id: appTheme
    }

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

    ScrollView {
        anchors.fill: parent
        clip: true

        GpsPanel {
            theme: appTheme
            width: parent.width
        }
    }

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
                        text: tr("مدیریت GPS", "GPS Manager")
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

            Button {
                width: parent.width
                text: tr("📍 داده‌های GPS", "📍 GPS Data")
                flat: true
                height: 50

                background: Rectangle {
                    color: parent.hovered ? appTheme.hoverColor : "transparent"
                    radius: 0
                }

                contentItem: Text {
                    text: parent.text
                    color: appTheme.textPrimary
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

            Button {
                width: parent.width
                text: tr("⚙️ تنظیمات", "⚙️ Settings")
                flat: true
                height: 50

                background: Rectangle {
                    color: parent.hovered ? appTheme.hoverColor : "transparent"
                    radius: 0
                }

                contentItem: Text {
                    text: parent.text
                    color: appTheme.textPrimary
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

            Button {
                width: parent.width
                text: tr("ℹ️ درباره", "ℹ️ About")
                flat: true
                height: 50

                background: Rectangle {
                    color: parent.hovered ? appTheme.hoverColor : "transparent"
                    radius: 0
                }

                contentItem: Text {
                    text: parent.text
                    color: appTheme.textPrimary
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

    Dialog {
        id: settingsDialog
        title: tr("تنظیمات", "Settings")
        modal: true
        anchors.centerIn: parent
        width: Math.min(parent.width * 0.8, 400)

        background: Rectangle {
            color: appTheme.surface
            border.color: appTheme.border
            border.width: 1
            radius: appTheme.radius.md
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 20

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Text {
                    text: tr("حالت تاریک", "Dark Mode")
                    font.pixelSize: 14
                    color: appTheme.textPrimary
                    Layout.fillWidth: true
                }

                Switch {
                    id: darkModeSwitch
                    checked: appTheme.isDarkMode
                    onCheckedChanged: appTheme.isDarkMode = checked
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Text {
                    text: tr("راست به چپ (RTL)", "Right To Left (RTL)")
                    font.pixelSize: 14
                    color: appTheme.textPrimary
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

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Text {
                    text: tr("حالت تست GPS (بدون ماهواره واقعی)", "Mock GPS Mode (No real satellites)")
                    font.pixelSize: 14
                    color: appTheme.textPrimary
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                }

                Switch {
                    id: mockGpsSwitch
                    checked: gpsManager.useMockData

                    onCheckedChanged: {
                        gpsManager.useMockData = checked
                        if (gpsManager.isValid) {
                            gpsManager.stopUpdates()
                            gpsManager.startUpdates()
                        }
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                text: tr(
                        "⚠️ این حالت فقط برای تست در محیط‌هایی که GPS ندارند استفاده شود",
                        "⚠️ This mode should only be used for testing where GPS is unavailable"
                    )
                font.pixelSize: 11
                color: appTheme.accentOrange
                wrapMode: Text.WordWrap
                visible: mockGpsSwitch.checked
            }
        }

        standardButtons: Dialog.Close
    }

    Dialog {
        id: aboutDialog
        modal: true
        width: 350
        height: 500
        anchors.centerIn: Overlay.overlay

        background: Rectangle {
            color: appTheme.surface
            radius: appTheme.radius.md
            border.color: appTheme.border
            border.width: 1
        }

        AboutDialog {
            anchors.fill: parent
            theme: appTheme

            appName: "Sattellite Position Finder"
            appVersion: Qt.application.version
            appBuildDate: "2026-03-02"
            appDescription: "Industrial robot monitoring and control software."

            companyName: "verya"
            companyWebsite: "https://verya-co.ir/"
            companyEmail: "info@verya-co.ir"

            logoSource: "qrc:/icon.png"

            onCloseRequested: {
                aboutDialog.close()
            }
        }
    }

    Component.onCompleted: {
        qmlLoaded.connect(gpsManager.onQmlLoaded)
        qmlLoaded()
    }
}
