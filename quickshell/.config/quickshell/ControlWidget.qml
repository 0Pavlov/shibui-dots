import QtQuick
import Quickshell

// Use a Rectangle as the root item for this widget
Rectangle {
    id: root
    
    // -------------------------------------------------------------------------
    // VISUAL CONFIGURATION
    // -------------------------------------------------------------------------
    width: 50
    height: 32
    radius: 16 // Makes the corners rounded (half of height = pill shape)
    //color: "#1e1e2e" // Dark background color
    color: Theme.background // Color from Theme.qml

    // Border Logic:
    // We check `hoverArea.containsMouse`. If true, use one color from the Theme,
    // otherwise use different one
    border.width: 2.3
    // Example:
    //border.color: hoverArea.containsMouse ? "#26a168" : "#45475a"
    border.color: hoverArea.containsMouse ? Theme.borderActive : Theme.borderInactive

    // Behavior for adding animation for the color change
    Behavior on border.color {
        ColorAnimation {
            duration: 200
            easing.type: Easing.Bezier
            easing.bezierCurve: [0.2, 0.0, 0.0, 1.0]
        }
    }


    // The Animation Object (Overlay)
    // This sits on top of the root border. It is invisible (opacity 0) normally
    Rectangle {
        id: flashOverlay
        anchors.fill: parent
        radius: root.radius
        color: "transparent"      // No background, just border
        border.width: root.border.width
        border.color: Theme.success // The color to flash
        opacity: 0                // Start invisible

        // The animation sequence
        SequentialAnimation {
            id: flashAnim
            
            // Fade in quickly
            NumberAnimation {
                target: flashOverlay
                property: "opacity"
                to: 1
                duration: 400
                easing.type: Easing.Bezier
                easing.bezierCurve: [0.05, 0.7, 0.1, 1.0]
            }

            PauseAnimation { duration: 100 }
            
            // Fade out slowly
            NumberAnimation {
                target: flashOverlay
                property: "opacity"
                to: 0
                duration: 500
                easing.type: Easing.Bezier
                easing.bezierCurve: [0.3, 0.0, 0.8, 0.15]
            }
        }
    }


    // -------------------------------------------------------------------------
    // INTERACTION
    // -------------------------------------------------------------------------
    MouseArea {
        id: hoverArea
        // Fill the parent (the Rectangle) completely
        anchors.fill: parent
        // Required to detect hover state without clicking
        hoverEnabled: true 
    }

    // -------------------------------------------------------------------------
    // CONTENT
    // -------------------------------------------------------------------------

    Text {
        anchors.verticalCenter: parent.verticalCenter // Vertically centered
        anchors.horizontalCenter: parent.horizontalCenter // Vertically centered

        // Translate it slightly (for the icons that are not quet centered)
        transform: Translate { x: -1.1; y: -1 }

        // Just an Endeavour logo
        text: " "
        
        //color: "#cdd6f4"
        color: Theme.textPrimary
        font.pixelSize: 16
    }
}
