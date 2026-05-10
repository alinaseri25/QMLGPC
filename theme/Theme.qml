import QtQuick

QtObject {

    // ================= State =================
    property bool isDarkMode: true
    property bool isRTL: true

    // ================= Layout =================
    readonly property int headerHeight: 60

    // ================= Text =================
    readonly property color textPrimary: isDarkMode ? "#FFFFFF" : "#1A1A1A"
    readonly property color textSecondary: isDarkMode ? "#8A9AB8" : "#666666"
    readonly property color textOnAccent: "#FFFFFF"

    // ================= Surfaces =================
    readonly property color background: isDarkMode ? "#0A0E27" : "#F5F7FA"
    readonly property color surface: isDarkMode ? "#1A1F3A" : "#FFFFFF"
    readonly property color surfaceAlt: isDarkMode ? "#1A1F3A" : "#F0F0F0"
    readonly property color cardBackground: surface
    readonly property color headerBackground: surface

    // ================= Brand / Accent =================
    readonly property color primary: isDarkMode ? "#4A90E2" : "#2196F3"
    readonly property color accent: primary
    readonly property color accentGreen: "#4CAF50"
    readonly property color accentOrange: "#FF9800"
    readonly property color accentRed: "#F44336"
    readonly property color accentBlue: primary

    // ================= Borders / States =================
    readonly property color border: isDarkMode ? "#2A3F5F" : "#E0E0E0"
    readonly property color cardBorder: border
    readonly property color hoverColor: isDarkMode ? "#252B47" : "#F0F0F0"
    readonly property color error: accentRed

    // ================= Spacing =================
    readonly property QtObject spacing: QtObject {
        readonly property int xs: 4
        readonly property int sm: 8
        readonly property int md: 16
        readonly property int lg: 24
        readonly property int xl: 32
    }

    // ================= Radius =================
    readonly property QtObject radius: QtObject {
        readonly property int sm: 6
        readonly property int md: 12
        readonly property int lg: 16
        readonly property int xl: 20
    }

    // ================= Font Sizes =================
    readonly property QtObject fontSize: QtObject {
        readonly property int xs: 10
        readonly property int sm: 12
        readonly property int md: 14
        readonly property int lg: 18
        readonly property int xl: 24
    }

    // ================= Satellite Colors =================
    readonly property QtObject satellite: QtObject {
        readonly property color gps: "#4CAF50"
        readonly property color glonass: "#2196F3"
        readonly property color galileo: "#FF9800"
        readonly property color beidou: "#E91E63"
        readonly property color unknown: "#9E9E9E"
    }

    // ================= Helpers =================
    function textAlignment() {
        return isRTL ? Text.AlignRight : Text.AlignLeft
    }

    function drawerEdge() {
        return isRTL ? Qt.RightEdge : Qt.LeftEdge
    }

    function getSatelliteColor(system) {
        switch (system) {
        case 0: return satellite.gps
        case 1: return satellite.glonass
        case 2: return satellite.galileo
        case 3: return satellite.beidou
        default: return satellite.unknown
        }
    }

    function getSignalColor(snr) {
        if (snr >= 30) return accentGreen
        if (snr >= 20) return accentOrange
        return accentRed
    }
}
