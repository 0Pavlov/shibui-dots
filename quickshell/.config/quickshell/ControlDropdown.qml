import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

Scope {
    id: root
    
    // --- STATE ---
    property bool revealed: false

    // --- 1. TRIGGER ---
    // This is called by your ControlWidget.qml
    function toggle() {
        revealed = !revealed
        if (revealed) {
            focusTimer.restart()
            // Reset animation
            mainContent.scale = 0.96
            mainContent.opacity = 0
            entranceAnim.restart()
        }
    }

    Timer {
        id: focusTimer
        interval: 10
        onTriggered: { if (revealed) inputScope.forceActiveFocus() }
    }

    // --- 2. LOGIC ---
    // Automatically close the OSD if you click outside of it (Hyprland)
    HyprlandFocusGrab {
        id: focusGrab
        active: revealed
        windows: [osdWindow]
        onCleared: revealed = false
    }

    // --- 3. UI ---
    PanelWindow {
        id: osdWindow
        
        // Fixed dimensions for your blank canvas
        width: 320
        height: 400
        
        anchors.top: true
        anchors.bottom: false
        anchors.left: false
        anchors.right: true

        visible: revealed
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: revealed 
            ? WlrLayerKeyboardFocus.Exclusive 
            : WlrLayerKeyboardFocus.None

        FocusScope {
            id: inputScope
            anchors.fill: parent
            focus: true 
            
            onVisibleChanged: { if (visible) forceActiveFocus() }

            // Allow closing with Escape
            Keys.onEscapePressed: revealed = false

            // --- MAIN SURFACE ---
            Rectangle {
                id: mainContent
                anchors.fill: parent

                anchors.topMargin: 5
                anchors.rightMargin: 5
                
                radius: 16
                
                // Matches your theme logic
                color: Qt.alpha(Theme.background, 0.95)
                
                border.width: 2.3
                border.color: Theme.borderInactive
                
                // Entrance Animation (identical to your ThemeSwitcher)
                ParallelAnimation {
                    id: entranceAnim
                    NumberAnimation {
                        target: mainContent
                        property: "scale"
                        to: 1.0
                        duration: 300
                        easing.type: Easing.OutExpo 
                    }
                    NumberAnimation {
                        target: mainContent
                        property: "opacity"
                        to: 1.0
                        duration: 200
                        easing.type: Easing.OutQuad
                    }
                }

                // --- BLANK CANVAS FOR YOUR CONTENT ---
                // You can drop your Wifi/Bluetooth/Power buttons inside this Item
                Column {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12
                    
                    // Header
                    Text {
                        text: "CONTROL CENTER"
                        color: Theme.textSecondary
                        font.pixelSize: 10
                        font.letterSpacing: 2
                        font.bold: true
                        font.capitalization: Font.AllUppercase
                        opacity: 0.6
                        
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    // A little extra space below the title
                    Item { width: 1; height: 4 }

                    // --- MODULES ---
                    
                    WifiWidget {}
                    VolumeSlider {}
                    
                    // Future items will just drop right here:
                    // BrightnessSlider {}
                    // NetworkToggle {}

                }
            }
        }
    }
}
