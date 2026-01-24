import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland

Scope {
    // --- STATE ---
    property bool revealed: false
    property int selectedIndex: 0
    
    ListModel {
        id: themeModel
        ListElement { name: "shibui"; label: "Shibui" }
        ListElement { name: "zen";    label: "Zen" }
    }

    // --- 1. TRIGGER ---
    GlobalShortcut {
        name: "theme_switcher"
        onPressed: {
            revealed = !revealed
            if (revealed) {
                selectedIndex = 0
                focusTimer.restart()
                // Reset animation
                mainContent.scale = 0.96
                mainContent.opacity = 0
                entranceAnim.restart()
            }
        }
    }

    Timer {
        id: focusTimer
        interval: 10
        onTriggered: { if (revealed) inputScope.forceActiveFocus() }
    }

    // --- 2. LOGIC ---
    HyprlandFocusGrab {
        id: focusGrab
        active: revealed
        windows: [osdWindow]
        onCleared: revealed = false
    }

    Process {
        id: pythonProcess
        command: ["sh", "-c", "python3 ~/.config/theme-switcher/theme_switcher.py " + targetTheme]
        property string targetTheme: ""
        onRunningChanged: {
            if (running) console.log("[OSD] Applying theme: " + targetTheme)
        }
    }

    function applyTheme() {
        const name = themeModel.get(selectedIndex).name
        pythonProcess.targetTheme = name
        pythonProcess.running = true
        revealed = false
    }

    // --- 3. UI ---
    PanelWindow {
        id: osdWindow
        
        // Fixed width, Dynamic height based on content
        width: 320
        height: mainContent.height
        
        anchors.top: false
        anchors.bottom: false
        anchors.left: false
        anchors.right: false

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

            Keys.onUpPressed:   if (selectedIndex > 0) selectedIndex--
            Keys.onDownPressed: if (selectedIndex < themeModel.count - 1) selectedIndex++
            Keys.onReturnPressed: applyTheme()
            Keys.onEnterPressed:  applyTheme()
            Keys.onEscapePressed: revealed = false

            // --- MAIN SURFACE ---
            Rectangle {
                id: mainContent
                width: parent.width
                // Calculate height: Header + List + Padding
                height: layoutColumn.implicitHeight + 32 
                
                radius: 16
                
                color: Qt.alpha(Theme.background, 0.95)
                
                border.width: 1
                border.color: Theme.borderInactive
                
                // Animation
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

                Column {
                    id: layoutColumn
                    anchors.centerIn: parent
                    width: parent.width - 32 // 16px padding on sides
                    spacing: 12

                    // --- HEADER ---
                    Text {
                        text: "SELECT THEME"
                        color: Theme.textSecondary
                        font.pixelSize: 10
                        font.letterSpacing: 2
                        font.bold: true
                        font.capitalization: Font.AllUppercase
                        opacity: 0.6
                        
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    // --- LIST ---
                    Column {
                        width: parent.width
                        spacing: 6

                        Repeater {
                            model: themeModel
                            delegate: Rectangle {
                                width: parent.width
                                height: 44 
                                radius: 10
                                
                                property bool isSelected: index === selectedIndex

                                // Background: Slight tint when selected
                                color: isSelected ? Qt.alpha(Theme.textPrimary, 0.05) : "transparent"
                                
                                border.width: 2.3
                                border.color: isSelected ? Theme.borderActive : "transparent"
                                
                                Behavior on color { ColorAnimation { duration: 100 } }
                                Behavior on border.color { ColorAnimation { duration: 100 } }

                                Text {
                                    text: label
                                    anchors.centerIn: parent
                                    font.pixelSize: 15
                                    font.weight: isSelected ? Font.DemiBold : Font.Medium
                                    color: isSelected ? Theme.textPrimary : Theme.textSecondary
                                    
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
