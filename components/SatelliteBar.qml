import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    width: 70
    height: 180

    required property var theme
    property int satelliteId: 0
    property real signalStrength: 0
    property int systemType: 0
    property bool inUse: false

    function getSystemName(type) {
        switch(type) {
            case 0: return "GPS"
            case 1: return "GLO"
            case 2: return "GAL"
            case 3: return "BDS"
            case 4: return "QZS"
            case 5: return "NAV"
            default: return "UNK"
        }
    }

    function getSignalColor(strength) {
        if (strength >= 40) return theme.accentGreen
        if (strength >= 30) return theme.primary
        if (strength >= 20) return theme.accentOrange
        return theme.accentRed
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 6

        // میله سیگنال
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            Layout.minimumHeight: 120

            // پس‌زمینه میله
            Rectangle {
                id: backgroundBar
                anchors.bottom: parent.bottom
                width: parent.width
                height: parent.height
                color: theme.surface
                radius: 6
                opacity: 0.3
                border.color: theme.border
                border.width: 1
            }

            // میله اصلی سیگنال
            Rectangle {
                id: signalBar
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                height: Math.max((root.signalStrength / 50) * 120, 10)
                color: getSignalColor(root.signalStrength)
                radius: 6
                opacity: root.inUse ? 1.0 : 0.6

                Behavior on height {
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on color {
                    ColorAnimation { duration: 300 }
                }

                // مقدار سیگنال (عدد)
                Text {
                    anchors.centerIn: parent
                    text: Math.round(root.signalStrength)
                    font.pixelSize: 14
                    font.bold: true
                    color: "white"
                    visible: root.signalStrength > 8
                    style: Text.Outline
                    styleColor: "black"
                }
            }
        }

        // شماره ماهواره
        Text {
            Layout.fillWidth: true
            text: "ID: " + root.satelliteId.toString()
            font.pixelSize: 11
            font.bold: true
            color: theme.text
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }

        // نوع سیستم
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 22
            color: theme.surface
            radius: 4
            border.color: theme.border
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: getSystemName(root.systemType)
                font.pixelSize: 10
                font.bold: true
                color: theme.textSecondary
            }
        }

        // نشانگر "در حال استفاده"
        Rectangle {
            visible: root.inUse
            Layout.preferredWidth: 10
            Layout.preferredHeight: 10
            Layout.alignment: Qt.AlignHCenter
            radius: 5
            color: theme.accentGreen

            SequentialAnimation on opacity {
                running: root.inUse
                loops: Animation.Infinite
                NumberAnimation { to: 0.2; duration: 700 }
                NumberAnimation { to: 1.0; duration: 700 }
            }
        }
    }
}
