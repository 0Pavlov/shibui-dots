import QtQuick
import Quickshell
import Quickshell.Hyprland

Rectangle {
    id: root

    // -------------------------------------------------------------------------
    // VISUAL CONFIGURATION
    // -------------------------------------------------------------------------
    
    // Dynamic width: content width + left/right padding (15 + 15 = 30)
    implicitWidth: workspaceRow.width + 30
    height: 32
    radius: 16
    
    // Matches SystemStatusWidget theme
    color: Theme.background 

    // Border Logic
    border.width: 2.3
    border.color: hoverArea.containsMouse ? Theme.borderActive : Theme.borderInactive

    // Smooth color transition for border
    Behavior on border.color {
        ColorAnimation {
            duration: 200
            easing.type: Easing.Bezier
            easing.bezierCurve: [0.2, 0.0, 0.0, 1.0]
        }
    }

    // -------------------------------------------------------------------------
    // INTERACTION (Hover only)
    // -------------------------------------------------------------------------
    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        // Important: propagate clicks to the children (the workspace buttons)
        propagateComposedEvents: true 
    }

    // -------------------------------------------------------------------------
    // CONTENT
    // -------------------------------------------------------------------------
    Row {
        id: workspaceRow
        anchors.centerIn: parent
        spacing: 12 

        Repeater {
            // Quickshell's Hyprland service provides this list automatically
            model: Hyprland.workspaces

            delegate: Rectangle {
                id: workspaceItem
                // modelData is the HyprlandWorkspace object
                width: 20 
                height: 20
                color: "transparent"

                // Check if this workspace is the focused one
                readonly property bool isActive: Hyprland.focusedWorkspace && modelData.id === Hyprland.focusedWorkspace.id

                Text {
                    anchors.centerIn: parent
                    text: modelData.id
                    
                    // Example:
                    // Green (#a6e3a1) if active, White (#cdd6f4) if inactive
                    color: workspaceItem.isActive ? Theme.success : Theme.textPrimary
                    
                    font.pixelSize: 14
                    font.bold: true
                }

                // Click to switch
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Hyprland.dispatch("workspace", modelData.id)
                    }
                }
            }
        }
    }
}
