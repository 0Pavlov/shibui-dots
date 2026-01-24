import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

Scope {
    property int displayTime: 700
    property int fadeTime: 100
    property string currentLayout: "??"
    property bool revealed: false
    
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "activelayout") {
                const data = event.data.split(",");
                if (data.length >= 2) {
                    let layoutName = data[1];
                    const mappings = { "English (US)": "EN", "Russian": "RU" };
                    
                    if (mappings[layoutName]) {
                        layoutName = mappings[layoutName];
                    } else {
                        layoutName = layoutName.substring(0, 2).toUpperCase();
                    }

                    currentLayout = layoutName;
                    revealed = true;
                    hideTimer.restart();
                }
            }
        }
    }

    Timer {
        id: hideTimer
        interval: displayTime
        onTriggered: revealed = false
    }

    PanelWindow {
        id: osdWindow
        
        property var activeMonitor: Hyprland.focusedMonitor || Quickshell.screens[0]
        screen: activeMonitor ? activeMonitor.screen : null
        
        // --- POSITION AND SIZE ---
        width: 160
        height: 160

        anchors {
            top: false
            bottom: true
            left: false
            right: false
        }
        margins.bottom: 100
        // --- POSITION AND SIZE ---

        WlrLayershell.layer: WlrLayer.Overlay
        exclusionMode: ExclusionMode.Ignore

        color: "transparent"
        visible: content.opacity > 0

        Rectangle {
            id: content
            anchors.fill: parent
            radius: 24
            
            // --- THEME INTEGRATION ---
            // Use the background, but make it 85% opaque for the glass effect
            color: Qt.alpha(Theme.background, 0.85)
            
            // Add a subtle border to define the shape against wallpapers
            border.width: 1
            border.color: Theme.borderInactive
            // -------------------------

            opacity: revealed ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: fadeTime } }

            Column {
                anchors.centerIn: parent
                spacing: 10

                Text {
                    text: "⌨"
                    // Use Theme Text Color
                    color: Theme.textPrimary
                    font.pixelSize: 48
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: currentLayout
                    // Use Theme Text Color
                    color: Theme.textPrimary
                    font.bold: true
                    font.pixelSize: 32
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }
}
