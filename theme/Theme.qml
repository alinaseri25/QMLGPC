import QtQuick

QtObject {
    id: theme

    // =============== تنظیمات زبان و حالت ===============
    property bool isRTL: true
    property bool isDarkMode: true

    // =============== رنگ‌های پویا (Dark/Light) ===============
    readonly property color background: isDarkMode ? "#0A0E27" : "#F5F7FA"
    readonly property color surface: isDarkMode ? "#1A1F3A" : "#FFFFFF"
    readonly property color primary: isDarkMode ? "#4A90E2" : "#2196F3"
    readonly property color border: isDarkMode ? "#2A3F5F" : "#E0E0E0"

    // رنگ‌های متن
    readonly property color text: isDarkMode ? "#FFFFFF" : "#1A1A1A"
    readonly property color textSecondary: isDarkMode ? "#8A9AB8" : "#666666"

    // رنگ‌های تاکیدی (ثابت در هر دو حالت)
    readonly property color accentGreen: "#4CAF50"
    readonly property color accentOrange: "#FF9800"
    readonly property color accentRed: "#F44336"

    // رنگ هاور
    readonly property color hoverColor: isDarkMode ? "#252B47" : "#F0F0F0"

    // =============== اندازه‌ها ===============
    readonly property int radius: 12
    readonly property int cardPadding: 16
    readonly property int headerHeight: 60

    // فاصله‌گذاری
    readonly property int spacing: 16
    readonly property int spacingSmall: 8
    readonly property int spacingMedium: 16
    readonly property int spacingLarge: 24

    // اندازه فونت
    readonly property int fontSizeSmall: 12
    readonly property int fontSizeMedium: 14
    readonly property int fontSizeLarge: 18
    readonly property int fontSizeXLarge: 24

    // =============== رنگ‌های ماهواره ===============
    readonly property color satelliteGps: "#4CAF50"
    readonly property color satelliteGlonass: "#2196F3"
    readonly property color satelliteGalileo: "#FF9800"
    readonly property color satelliteBeidou: "#E91E63"
    readonly property color satelliteUnknown: "#9E9E9E"

    // =============== توابع کمکی ===============
    function textAlignment() {
        return isRTL ? Text.AlignRight : Text.AlignLeft
    }

    function drawerEdge() {
        return isRTL ? Qt.RightEdge : Qt.LeftEdge
    }

    function getSatelliteColor(system) {
        switch(system) {
            case 0: return satelliteGps
            case 1: return satelliteGlonass
            case 2: return satelliteGalileo
            case 3: return satelliteBeidou
            default: return satelliteUnknown
        }
    }

    function getSignalColor(snr) {
        if (snr >= 30) return accentGreen
        if (snr >= 20) return accentOrange
        return accentRed
    }
}
