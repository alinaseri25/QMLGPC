import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QMLGPC
import "../components"

Item {
    required property var theme

    id: root
    implicitHeight: mainColumn.height

    signal copyGeoData()

    ColumnLayout {
        id: mainColumn
        width: parent.width
        spacing: 16

        // دکمه‌های کنترل
        RowLayout {
            Layout.fillWidth: true
            Layout.margins: 16
            spacing: 12

            Button {
                text: gpsManager.isValid ? "متوقف کردن GPS" : "شروع GPS"
                Layout.fillWidth: true

                background: Rectangle {
                    color: parent.pressed ? theme.primary : (parent.hovered ? Qt.lighter(theme.surface, 1.1) : theme.surface)
                    radius: theme.radius
                    border.color: theme.border
                    border.width: 1
                }

                contentItem: Text {
                    text: parent.text
                    color: theme.text
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 14
                }

                onClicked: {
                    if (gpsManager.isValid) {
                        gpsManager.stopUpdates()
                    } else {
                        gpsManager.startUpdates()
                    }
                }
            }

            Button {
                text: "کپی کردن مختصات"
                Layout.fillWidth: true

                background: Rectangle {
                    color: parent.pressed ? theme.primary : (parent.hovered ? Qt.lighter(theme.surface, 1.1) : theme.surface)
                    radius: theme.radius
                    border.color: theme.border
                    border.width: 1
                }

                contentItem: Text {
                    text: parent.text
                    color: theme.text
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 14
                }

                onClicked: {
                    copyGeoData()
                }
            }

            Button {
                text: "بروزرسانی ماهواره‌ها"
                Layout.fillWidth: true
                enabled: gpsManager.isValid

                background: Rectangle {
                    color: parent.pressed ? theme.primary : (parent.hovered ? Qt.lighter(theme.surface, 1.1) : theme.surface)
                    opacity: parent.enabled ? 1.0 : 0.5
                    radius: theme.radius
                    border.color: theme.border
                    border.width: 1
                }

                contentItem: Text {
                    text: parent.text
                    color: theme.text
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 14
                }

                onClicked: satelliteView.updateSatellites()
            }
        }

        // پیام وضعیت
        Rectangle {
            Layout.fillWidth: true
            Layout.margins: 16
            height: 50
            color: gpsManager.isValid ? theme.accentGreen : theme.accentOrange
            radius: theme.radius

            Text {
                anchors.centerIn: parent
                text: gpsManager.statusMessage
                color: "white"
                font.pixelSize: 16
                font.bold: true
            }
        }

        // کارت‌های داده GPS
        GridLayout {
            Layout.fillWidth: true
            Layout.margins: 16
            columns: 2
            rowSpacing: 12
            columnSpacing: 12

            GpsDataCard {
                theme: root.theme
                Layout.fillWidth: true
                title: "عرض جغرافیایی"
                value: gpsManager.isValid ? gpsManager.latitude.toFixed(6) : "---"
                unit: "°"
                icon: "📍"
            }

            GpsDataCard {
                theme: root.theme
                Layout.fillWidth: true
                title: "طول جغرافیایی"
                value: gpsManager.isValid ? gpsManager.longitude.toFixed(6) : "---"
                unit: "°"
                icon: "📍"
            }

            GpsDataCard {
                theme: root.theme
                Layout.fillWidth: true
                title: "ارتفاع"
                value: gpsManager.isValid ? gpsManager.altitude.toFixed(1) : "---"
                unit: "متر"
                icon: "⛰️"
            }

            GpsDataCard {
                theme: root.theme
                Layout.fillWidth: true
                title: "سرعت"
                value: gpsManager.isValid ? (gpsManager.speed * 3.6).toFixed(1) : "---"
                unit: "کیلومتر/ساعت"
                icon: "🚀"
            }

            GpsDataCard {
                theme: root.theme
                Layout.fillWidth: true
                title: "جهت"
                value: gpsManager.isValid ? gpsManager.direction.toFixed(0) : "---"
                unit: "درجه"
                icon: "🧭"
            }

            GpsDataCard {
                theme: root.theme
                Layout.fillWidth: true
                title: "دقت افقی"
                value: gpsManager.isValid ? gpsManager.horizontalAccuracy.toFixed(1) : "---"
                unit: "متر"
                icon: "📏"
            }

            GpsDataCard {
                theme: root.theme
                Layout.fillWidth: true
                title: "دقت عمودی"
                value: gpsManager.isValid ? gpsManager.verticalAccuracy.toFixed(1) : "---"
                unit: "متر"
                icon: "📐"
            }

            GpsDataCard {
                theme: root.theme
                Layout.fillWidth: true
                title: "زمان"
                value: gpsManager.isValid ? gpsManager.timestamp : "---"
                unit: ""
                icon: "⏰"
            }
        }

        // اطلاعات ماهواره
        Rectangle {
            Layout.fillWidth: true
            Layout.margins: 16
            height: 80
            color: theme.surface
            radius: theme.radius
            border.color: theme.border
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 20

                Column {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        width: parent.width
                        text: "کل ماهواره‌ها"
                        font.pixelSize: 12
                        color: theme.textSecondary
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Text {
                        width: parent.width
                        text: gpsManager.satelliteCount.toString()
                        font.pixelSize: 28
                        font.bold: true
                        color: theme.text
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                Rectangle {
                    width: 1
                    Layout.fillHeight: true
                    color: theme.border
                }

                Column {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        width: parent.width
                        text: "در حال استفاده"
                        font.pixelSize: 12
                        color: theme.textSecondary
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Text {
                        width: parent.width
                        text: gpsManager.satellitesInUse.toString()
                        font.pixelSize: 28
                        font.bold: true
                        color: theme.primary
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }

        // نمودار ماهواره‌ها
        SatelliteView {
            id: satelliteView
            theme: root.theme
            Layout.fillWidth: true
            Layout.preferredHeight: 450
            Layout.margins: 16
            Layout.bottomMargin: 32
        }
    }
    Component.onCompleted: {
        copyGeoData.connect(gpsManager.onCopyGeoData)
    }
}
