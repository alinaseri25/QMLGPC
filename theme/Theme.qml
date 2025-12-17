pragma Singleton

import QtQuick

QtObject {
    id: theme

    // =============== RTL & Language Support ===============
    property bool isRTL: false

    // =============== Colors - Background ===============
    readonly property color background: "#0a0e14"
    readonly property color backgroundColor: "#0a0e14"
    readonly property color surface: "#151a23"
    readonly property color cardBackground: "#151a23"
    readonly property color headerBackground: "#151a23"

    // =============== Colors - Text ===============
    readonly property color text: "#ffffff"
    readonly property color primaryText: "#ffffff"
    readonly property color secondaryText: "#8b949e"
    readonly property color textSecondary: "#8b949e"  // ← اضافه شد

    // =============== Colors - Border ===============
    readonly property color border: "#2d333b"
    readonly property color borderColor: "#2d333b"

    // =============== Colors - Accent ===============
    readonly property color primary: "#2ecc71"  // ← اضافه شد
    readonly property color accentGreen: "#2ecc71"
    readonly property color accentOrange: "#f39c12"
    readonly property color accentRed: "#e74c3c"
    readonly property color hoverColor: "#1e2530"

    // =============== Fonts ===============
    readonly property int fontSizeSmall: 12
    readonly property int fontSizeMedium: 14
    readonly property int fontSizeLarge: 18
    readonly property int fontSizeXLarge: 24

    // =============== Sizes ===============
    readonly property int radius: 12
    readonly property int borderRadius: 12
    readonly property int spacing: 16
    readonly property int spacingSmall: 8
    readonly property int spacingMedium: 16
    readonly property int spacingLarge: 24
    readonly property int cardPadding: 16

    // =============== Satellite Colors ===============
    readonly property color satelliteGps: "#4CAF50"
    readonly property color satelliteGlonass: "#2196F3"
    readonly property color satelliteGalileo: "#FF9800"
    readonly property color satelliteBeidou: "#E91E63"
    readonly property color satelliteUnknown: "#9E9E9E"

    // =============== Dark Mode ===============
    property bool isDarkMode: true  // ← نباید readonly باشه

    // =============== Helper Functions ===============
    function getSatelliteColor(system) {
        switch(system) {
            case "GPS": return satelliteGps
            case "GLONASS": return satelliteGlonass
            case "Galileo": return satelliteGalileo
            case "BeiDou": return satelliteBeidou
            default: return satelliteUnknown
        }
    }

    function getSignalColor(snr) {
        if (snr >= 30) return accentGreen
        if (snr >= 20) return accentOrange
        return accentRed
    }

    function textAlignment() {
        return isRTL ? Text.AlignRight : Text.AlignLeft
    }

    function drawerEdge() {
        return isRTL ? Qt.RightEdge : Qt.LeftEdge
    }
}
