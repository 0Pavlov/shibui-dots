pragma Singleton
import QtQuick

QtObject {
    // Backgrounds
    // A deep "Ink" black. Softer than #000000 to reduce eye strain
    property color background: "#121212"
    
    // Borders & Dividers
    // Pure white allows the active element to "pop" without color
    property color borderActive: "#dedede"
    property color borderInactive: "#333333"
    property color divider: "#262626"

    // Text Colors
    property color textPrimary: "#dedede"   // Off-white (Rice paper) for readability
    property color textSecondary: "#808080" // Neutral grey for non-critical info
    
    // Status / Accents
    // In a monochrome theme, semantic meaning (Good/Bad) is conveyed 
    // through brightness/contrast or icons rather than hue
    property color success: "#ffffff" // Pure bright white
    property color error: "#f7768e"   // Error color
    property color warning: "#ff9e64" // Orange
}
