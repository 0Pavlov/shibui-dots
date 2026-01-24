pragma Singleton
import QtQuick

QtObject {
    // Backgrounds
    property color background: "#1e1e2e"
    
    // Borders & Dividers
    property color borderActive: "#26a168"
    property color borderInactive: "#45475a"
    property color divider: "#585b70"

    // Text Colors
    property color textPrimary: "#cdd6f4"
    property color textSecondary: "#a6adc8" // Added for future use
    
    // Status / Accents
    property color success: "#a6e3a1" // Green for charging
    property color error: "#f38ba8"   // Red (good to have for low battery later)
    property color warning: "#ff9e64" // Orange
}
