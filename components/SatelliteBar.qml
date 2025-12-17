import QtQuick
import QtQuick.Controls
import QMLGPC

Item {
    id: root
    width: 60
    height: 150

    required property var theme
    property int satelliteId: 0
    property real signalStrength: 0
    property int systemType: 0
    property bool inUse: false

    // تابع تبدیل نوع سیستم به نام
    function getSystemName(type) {
        switch(type) {
            case 0: return "GPS"
            case 1: return "GLO"  // GLONASS
            case 2: return "GAL"  // Galileo
            case 3: return "BDS"  // BeiDou
            case 4: return "QZS"  // QZSS
            case 5: return "NAV"  // NavIC
            default: return "UNK"
        }
    }

    // ✅ استفاده از رنگ‌های موجود در theme
    function getSignalColor(strength) {
        if (strength >= 40) return theme.accentGreen
        if (strength >= 30) return theme.primary
        if (strength >= 20) return theme.accentOrange
        return theme.accentRed
    }

    Column {
        anchors.fill: parent
        spacing: 4

        // میله سیگنال
        Item {
            width: parent.width
            height: 100

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: Math.max((root.signalStrength / 50) * 100, 5)
                color: getSignalColor(root.signalStrength)
                radius: 4
                opacity: root.inUse ? 1.0 : 0.5

                Behavior on height {
                    NumberAnimation { duration: 300; easing.type: Easing.OutQuad }
                }

                // مقدار سیگنال
                Text {
                    anchors.centerIn: parent
                    text: Math.round(root.signalStrength)
                    font.pixelSize: 10
                    font.bold: true
                    color: "white"
                    visible: root.signalStrength > 0
                }
            }
        }

        // شماره ماهواره
        Text {
            width: parent.width
            text: root.satelliteId.toString()
            font.pixelSize: 11
            font.bold: true
            color: theme.text  // ✅ تصحیح: primaryTextColor → text
            horizontalAlignment: Text.AlignHCenter
        }

        // نوع سیستم
        Text {
            width: parent.width
            text: getSystemName(root.systemType)
            font.pixelSize: 9
            color: theme.textSecondary  // ✅ تصحیح: secondaryTextColor → textSecondary
            horizontalAlignment: Text.AlignHCenter
        }

        // نشانگر "در حال استفاده"
        Rectangle {
            visible: root.inUse
            width: 6
            height: 6
            radius: 3
            color: theme.accentGreen  // ✅ تصحیح: successColor → accentGreen
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
