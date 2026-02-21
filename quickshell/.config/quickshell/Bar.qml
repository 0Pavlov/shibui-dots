import QtQuick
import Quickshell

Scope {
    // Variants creates multiple copies of a component based on a model
    // Here, the model is the list of connected screens
    Variants {
        model: Quickshell.screens

        // The component to create for every screen
        // We define the PanelWindow directly inside Variants
        PanelWindow {
            // Quickshell injects the specific screen object into 'modelData'
            // We must accept it as a property
            property var modelData
            
            // Assign this window to that specific screen
            screen: modelData

            // -----------------------------------------------------------------
            // WINDOW GEOMETRY
            // -----------------------------------------------------------------
            implicitHeight: 37
            
            // Anchors allow the window to stretch across the top of the screen
            anchors {
                top: true
                left: true
                right: true
            }

            // Transparent because the "StatusStatusWidget" provides the background color
            color: "transparent"

            // -----------------------------------------------------------------
            // CHILD WIDGETS
            // -----------------------------------------------------------------
            
            // Place the separated widget component into the window
            SystemStatusWidget {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
            }
            WorkspacesWidget {
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                anchors.leftMargin: 5
            }
            ControlWidget {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.rightMargin: 5
            }
        }
    }
}
