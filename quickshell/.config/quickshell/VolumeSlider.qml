import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire

Rectangle {
    id: root
    
    // Fill the width of the parent (the Column in the OSD)
    width: parent.width
    height: 56
    radius: 12
    
    // Subtle background to separate it from the OSD canvas
    color: Qt.alpha(Theme.textPrimary, 0.03)
    border.width: 1
    border.color: Qt.alpha(Theme.borderInactive, 0.5)

    // --- PIPEWIRE LOGIC ---
    // Track the default sink to react to volume changes from media keys / other apps
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    property var sink: Pipewire.defaultAudioSink
    
    // Safely get volume and mute state, defaulting to 0/false if not loaded yet
    property real currentVolume: sink && sink.audio ? sink.audio.volume : 0
    property bool isMuted: sink && sink.audio ? sink.audio.muted : false

    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        // 1. MUTE BUTTON / ICON
        Rectangle {
            width: 32
            height: 32
            radius: 8
            color: root.isMuted ? Qt.alpha(Theme.error, 0.15) : "transparent"
            
            Text {
                anchors.centerIn: parent
                // Standard NerdFont icons
                text: root.isMuted ? "󰖁" : (root.currentVolume > 0.4 ? "󰕾" : (root.currentVolume > 0 ? "󰖀" : "󰕿"))
                color: root.isMuted ? Theme.error : Theme.textPrimary
                font.pixelSize: 18
            }
            
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (root.sink && root.sink.audio) {
                        root.sink.audio.muted = !root.sink.audio.muted
                    }
                }
            }
        }

        // 2. CUSTOM SLIDER TRACK
        Item {
            Layout.fillWidth: true
            height: 24
            
            // Background track
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                height: 6
                radius: 3
                color: Qt.alpha(Theme.textPrimary, 0.1)
                
                // Active fill (Volume Level)
                Rectangle {
                    height: parent.height
                    // Width is a percentage of the total track width (clamped 0-1)
                    width: parent.width * Math.min(Math.max(root.currentVolume, 0), 1)
                    radius: 3
                    
                    // Gray out if muted, otherwise use your active theme color
                    color: root.isMuted ? Theme.textSecondary : Theme.borderActive
                    
                    // Smooth visual updates when changed externally
                    Behavior on width {
                        NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
                    }
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }
            }
            
            // Invisible interaction layer
            MouseArea {
                anchors.fill: parent
                
                function updateVolume(mouse) {
                    if (root.sink && root.sink.audio) {
                        // Calculate percentage based on click/drag X position
                        let percent = mouse.x / width
                        percent = Math.max(0.0, Math.min(1.0, percent)) // Clamp 0-1
                        
                        // Automatically unmute if you drag the slider up
                        if (root.sink.audio.muted && percent > 0) {
                            root.sink.audio.muted = false
                        }
                        
                        root.sink.audio.volume = percent
                    }
                }
                
                // Allow both dragging and clicking
                onPositionChanged: (mouse) => { if (pressed) updateVolume(mouse) }
                onPressed: (mouse) => updateVolume(mouse)
            }
        }
        
        // 3. PERCENTAGE TEXT
        Text {
            // Format to integer percentage
            text: Math.round(root.currentVolume * 100) + "%"
            color: root.isMuted ? Theme.textSecondary : Theme.textPrimary
            font.pixelSize: 13
            font.weight: Font.Medium
            Layout.minimumWidth: 35
            horizontalAlignment: Text.AlignRight
        }
    }
}
