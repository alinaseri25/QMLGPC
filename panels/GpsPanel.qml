import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QMLGPC
import "../components"

Item {
    required property var theme

    // تابعی برای ترجمه سریع و شرطی
    function tr(fa, en) {
        return theme.isRTL ? fa : en
    }

    id: root
    implicitHeight: mainColumn.height

    signal copyGeoData()
    signal stopUpdates()
    signal startUpdates()

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
                id: btnStartStop
                text: tr("شروع GPS", "Start GPS")
                Layout.fillWidth: true

                background: Rectangle {
                    color: parent.pressed ? theme.primary : (parent.hovered ? Qt.lighter(theme.surface, 1.1) : theme.surface)
                    radius: theme.radius.md
                    border.color: theme.border
                    border.width: 1
                }

                contentItem: Text {
                    text: parent.text
                    color: theme.textPrimary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 14
                }

                onClicked: {
                    // استفاده از tr برای مقایسه منطقی
                    if (text !== tr("شروع GPS", "Start GPS")) {
                        stopUpdates()
                    } else {
                        startUpdates()
                    }
                }
            }

            Button {
                id: btnCopyGeoData
                text: tr("کپی کردن مختصات", "Copy Coordinates")
                Layout.fillWidth: true
                enabled: false

                background: Rectangle {
                    color: parent.pressed ? theme.primary : (parent.hovered ? Qt.lighter(theme.surface, 1.1) : theme.surface)
                    opacity: parent.enabled ? 1.0 : 0.5
                    radius: theme.radius.md
                    border.color: theme.border
                    border.width: 1
                }

                contentItem: Text {
                    text: parent.text
                    color: theme.textPrimary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 14
                }

                onClicked: {
                    copyGeoData()
                }
            }

            Button {
                id: btnSatelliteUpdate
                text: tr("بروزرسانی ماهواره‌ها", "Update Satellites")
                Layout.fillWidth: true
                enabled: false

                background: Rectangle {
                    color: parent.pressed ? theme.primary : (parent.hovered ? Qt.lighter(theme.surface, 1.1) : theme.surface)
                    opacity: parent.enabled ? 1.0 : 0.5
                    radius: theme.radius.md
                    border.color: theme.border
                    border.width: 1
                }

                contentItem: Text {
                    text: parent.text
                    color: theme.textPrimary
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
            radius: theme.radius.md

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
                title: tr("عرض جغرافیایی", "Latitude")
                value: gpsManager.isValid ? gpsManager.latitude.toFixed(6) : "---"
                unit: "°"
                icon: "📍"
            }

            GpsDataCard {
                theme: root.theme
                Layout.fillWidth: true
                title: tr("طول جغرافیایی", "Longitude")
                value: gpsManager.isValid ? gpsManager.longitude.toFixed(6) : "---"
                unit: "°"
                icon: "📍"
            }

            GpsDataCard {
                theme: root.theme
                Layout.fillWidth: true
                title: tr("ارتفاع", "Altitude")
                value: gpsManager.isValid ? gpsManager.altitude.toFixed(1) : "---"
                unit: tr("متر", "m")
                icon: "⛰️"
            }

            GpsDataCard {
                theme: root.theme
                Layout.fillWidth: true
                title: tr("سرعت", "Speed")
                value: gpsManager.isValid ? (gpsManager.speed * 3.6).toFixed(1) : "---"
                unit: tr("کیلومتر/ساعت", "km/h")
                icon: "🚀"
            }

            GpsDataCard {
                theme: root.theme
                Layout.fillWidth: true
                title: tr("جهت", "Direction")
                value: gpsManager.isValid ? gpsManager.direction.toFixed(0) : "---"
                unit: tr("درجه", "deg")
                icon: "🧭"
            }

            GpsDataCard {
                theme: root.theme
                Layout.fillWidth: true
                title: tr("دقت افقی", "Horizontal Accuracy")
                value: gpsManager.isValid ? gpsManager.horizontalAccuracy.toFixed(1) : "---"
                unit: tr("متر", "m")
                icon: "📏"
            }

            GpsDataCard {
                theme: root.theme
                Layout.fillWidth: true
                title: tr("دقت عمودی", "Vertical Accuracy")
                value: gpsManager.isValid ? gpsManager.verticalAccuracy.toFixed(1) : "---"
                unit: tr("متر", "m")
                icon: "📐"
            }

            GpsDataCard {
                theme: root.theme
                Layout.fillWidth: true
                title: tr("زمان", "Time")
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
            radius: theme.radius.md
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
                        text: tr("کل ماهواره‌ها", "Total Satellites")
                        font.pixelSize: 12
                        color: theme.textSecondary
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Text {
                        width: parent.width
                        text: gpsManager.satelliteCount.toString()
                        font.pixelSize: 28
                        font.bold: true
                        color: theme.textPrimary
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
                        text: tr("در حال استفاده", "In Use")
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

    Connections{
        target: gpsManager
        function onStateChanged(state){
            if(state === 0)
            {
                btnSatelliteUpdate.enabled = false
                btnStartStop.text = tr("شروع GPS", "Start GPS")
            }
            else if(state === 1)
            {
                btnSatelliteUpdate.enabled = false
                btnStartStop.text = tr("در انتظار GPS", "Waiting for GPS")
            }
            else if(state === 2)
            {
                btnSatelliteUpdate.enabled = true
                btnStartStop.text = tr("توقف GPS", "Stop GPS")
            }
            btnCopyGeoData.enabled = btnSatelliteUpdate.enabled
        }
    }

    Component.onCompleted: {
        copyGeoData.connect(gpsManager.onCopyGeoData)
        startUpdates.connect(gpsManager.startUpdates)
        stopUpdates.connect(gpsManager.stopUpdates)
    }
}
