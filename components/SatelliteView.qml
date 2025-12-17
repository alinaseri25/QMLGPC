import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: root

    required property var theme

    implicitHeight: 350

    // 🎯 اتصال به سیگنال‌های GpsManager
    Connections {
        target: gpsManager

        function onSatellitesUpdated() {
            console.log("🔔 onSatellitesUpdated signal received!")
            updateTimer.restart()
        }

        function onSatelliteCountChanged() {
            console.log("🔔 onSatelliteCountChanged signal received!")
            updateTimer.restart()
        }
    }

    // ⏱️ تایمر به‌روزرسانی (با Debounce)
    Timer {
        id: updateTimer
        interval: 100
        repeat: false
        onTriggered: {
            var sats = gpsManager.getSatellites()
            console.log("🔄 Updating satellite model, count:", sats.length)

            // ✅ چاپ دقیق property ها
            for (var i = 0; i < Math.min(sats.length, 3); i++) {
                var sat = sats[i]
                console.log("📡 SAT", (i+1), "| ID:", sat.id,
                           "| System:", sat.system,
                           "| SignalStrength:", sat.signalStrength,  // ✅ درست!
                           "| InUse:", sat.inUse)
            }

            // ✅ به‌روزرسانی بدون لوپ
            satelliteGrid.satelliteData = sats
        }
    }

    // 📦 کانتینر اصلی
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: theme.border
        border.width: 1
        radius: theme.radius

        // ✅ ScrollView برای اسکرول عمودی
        ScrollView {
            id: scrollView
            anchors.fill: parent
            anchors.margins: theme.spacing
            clip: true

            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: ScrollBar.AsNeeded

            // ✅ Grid Layout با property خاص برای data
            Grid {
                id: satelliteGrid
                width: scrollView.availableWidth  // ✅ عرض دقیق ScrollView
                columns: 5
                rowSpacing: 8
                columnSpacing: 8

                // ✅ استفاده از property به جای مستقیم model
                property var satelliteData: []

                Repeater {
                    model: satelliteGrid.satelliteData.length

                    // ✅ Delegate ساده‌تر با item جدا
                    Item {
                        id: satItem

                        // ✅ محاسبه عرض دقیق برای 5 ستون
                        width: (satelliteGrid.width - (satelliteGrid.columnSpacing * 4)) / 5
                        height: 250

                        // ✅ دریافت داده ماهواره با index
                        readonly property var satData: satelliteGrid.satelliteData[index]
                        readonly property int satId: satData ? satData.id : 0
                        readonly property int satSystem: satData ? satData.system : 0
                        readonly property int satSignal: satData ? (satData.signalStrength || 0) : 0  // ✅ اصلاح شد!
                        readonly property bool satInUse: satData ? satData.inUse : false

                        Rectangle {
                            anchors.fill: parent
                            color: theme.surface
                            radius: 4
                            border.color: satItem.satInUse ? Qt.lighter(theme.getSatelliteColor(satItem.satSystem), 1.5) : theme.border
                            border.width: satItem.satInUse ? 2 : 1

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 4
                                spacing: 4

                                // فضای خالی بالا
                                Item { Layout.fillHeight: true }

                                // 📊 مقدار سیگنال
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: satItem.satSignal + " dB"
                                    color: theme.getSignalColor(satItem.satSignal)
                                    font.pixelSize: 10
                                    font.bold: true
                                    visible: satItem.satSignal > 0
                                }

                                // میله سیگنال
                                Rectangle {
                                    id: signalBar
                                    Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                                    Layout.preferredWidth: parent.width * 0.6
                                    Layout.preferredHeight: Math.max((satItem.satSignal / 50.0) * 150, 4)
                                    color: theme.getSignalColor(satItem.satSignal)
                                    radius: 3

                                    Behavior on Layout.preferredHeight {
                                        NumberAnimation {
                                            duration: 400
                                            easing.type: Easing.OutCubic
                                        }
                                    }

                                    // گرادیانت
                                    gradient: Gradient {
                                        GradientStop { position: 0.0; color: Qt.lighter(theme.getSignalColor(satItem.satSignal), 1.3) }
                                        GradientStop { position: 1.0; color: theme.getSignalColor(satItem.satSignal) }
                                    }
                                }

                                // شماره ماهواره
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.bottomMargin: 2
                                    text: satItem.satId
                                    color: satItem.satInUse ? theme.text : theme.textSecondary
                                    font.pixelSize: 11
                                    font.bold: satItem.satInUse
                                }

                                // آیکون سیستم
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: getSystemIcon(satItem.satSystem)
                                    font.pixelSize: 12
                                    visible: satItem.satInUse
                                }
                            }

                            // MouseArea با ToolTip
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true

                                ToolTip.visible: containsMouse
                                ToolTip.delay: 300
                                ToolTip.text: "🛰️ ID: " + satItem.satId + "\n" +
                                              "📡 System: " + getSystemName(satItem.satSystem) + "\n" +
                                              "📶 Signal: " + satItem.satSignal + " dB\n" +
                                              "✓ In Use: " + (satItem.satInUse ? "Yes" : "No")
                            }
                        }
                    }
                }
            }
        }

        // پیام "ماهواره یافت نشد"
        Text {
            anchors.centerIn: parent
            text: theme.isRTL ? "🛰️ ماهواره‌ای یافت نشد" : "🛰️ No satellites"
            color: theme.textSecondary
            font.pixelSize: 14
            visible: satelliteGrid.satelliteData.length === 0
        }
    }

    // ✅ توابع کمکی
    function getSystemIcon(system) {
        switch(system) {
            case 0: return "🇺🇸"  // GPS
            case 1: return "🇷🇺"  // GLONASS
            case 2: return "🇪🇺"  // Galileo
            case 3: return "🇨🇳"  // BeiDou
            case 4: return "🇨🇳"  // BeiDou (دوباره)
            default: return "❓"
        }
    }

    function getSystemName(system) {
        switch(system) {
            case 0: return "GPS"
            case 1: return "GLONASS"
            case 2: return "Galileo"
            case 3: return "BeiDou"
            case 4: return "BeiDou"
            default: return "Unknown"
        }
    }

    // ✅ به‌روزرسانی اولیه
    Component.onCompleted: {
        console.log("✅ SatelliteView initialized")
        updateTimer.start()
    }
}
