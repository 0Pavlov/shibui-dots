import QtQuick
import Quickshell
import Quickshell.Services.UPower

// Use a Rectangle as the root item for this widget
Rectangle {
    id: root
    
    // -------------------------------------------------------------------------
    // VISUAL CONFIGURATION
    // -------------------------------------------------------------------------
    width: 200
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

    // Border animation on power plug connection
    // Listen for the power state change
    Connections {
        target: UPower
        function onOnBatteryChanged() {
            // If we are NO LONGER on battery, we are plugged in
            if (!UPower.onBattery) {
                flashAnim.start()
            }
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

    // Low battery border color animation
    Rectangle {
        id: lowBatteryOverlay
        anchors.fill: parent
        radius: root.radius
        color: "transparent"
        border.width: root.border.width
        // Check if percentage is <= 10%. If yes, use Error color
        // Otherwise (11% - 15%), use Warning color
        border.color: (UPower.displayDevice && UPower.displayDevice.percentage <= 0.10) 
                      ? Theme.error 
                      : Theme.warning
        opacity: 0 // Invisible by default

        // The main threshold for activating any color canges
        // Logic: Device exists + Under 15% + Currently running on Battery power
        readonly property bool active: UPower.displayDevice 
                                       && UPower.displayDevice.percentage <= 0.15
                                       && UPower.onBattery

        // When active become false (plugged in), force opacity to 0
        // It prevents animation from freezing the state on plug in
        onActiveChanged: {
            if (!active) {
                lowBatteryOverlay.opacity = 0
            }
        }

        SequentialAnimation {
            running: lowBatteryOverlay.active
            loops: Animation.Infinite
            
            // Slow "Breathing" effect
            NumberAnimation { 
                target: lowBatteryOverlay
                property: "opacity"
                from: 0; to: 1
                duration: 2500 
                easing.type: Easing.InOutSine 
            }
            NumberAnimation { 
                target: lowBatteryOverlay
                property: "opacity"
                from: 1; to: 0
                duration: 2500 
                easing.type: Easing.InOutSine 
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

    // The vertical line in the middle
    Rectangle {
        id: divider
        anchors.centerIn: parent
        width: 1
        height: 12
        //color: "#585b70"
        color: Theme.divider
    }

    // CLOCK TEXT
    Text {
        // Anchor to the LEFT side of the divider
        anchors.right: divider.left
        anchors.rightMargin: 15
        anchors.verticalCenter: parent.verticalCenter // Vertically centered

        // Retrieve the data from our Singleton file (TimeSource.qml)
        text: TimeSource.time
        
        //color: "#cdd6f4"
        color: Theme.textPrimary
        font.pixelSize: 14
        font.bold: true
    }

    // BATTERY TEXT
    Text {
        // Anchor to the RIGHT side of the divider
        anchors.left: divider.right
        anchors.leftMargin: 15
        anchors.verticalCenter: parent.verticalCenter

        // Logic: Check if displayDevice (primary battery) exists
        // If yes: Calculate percentage
        // If no: Show "AC" (Plugged in/Desktop mode)
        text: UPower.displayDevice 
              ? Math.round(UPower.displayDevice.percentage * 100) + "%" 
              : "AC"
        
        // Logic: 
        // If Charging/Plugged in -> Success
        // If Battery <= 10%      -> Error
        // If Battery <= 15%      -> Warning
        // Otherwise              -> Normal Text Color
        color: !UPower.onBattery 
               ? Theme.success 
               : (UPower.displayDevice && UPower.displayDevice.percentage <= 0.10)
                 ? Theme.error
                 : (UPower.displayDevice && UPower.displayDevice.percentage <= 0.15)
                   ? Theme.warning
                   : Theme.textPrimary
        
        font.pixelSize: 14
        font.bold: true
    }
}
