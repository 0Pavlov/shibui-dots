import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland

Scope {
    id: root
    property bool revealed: false
    property int selectedIndex: 0
    
    ListModel {
        id: themeModel
        ListElement { name: "shibui"; label: "Shibui" }
        ListElement { name: "zen";    label: "Zen" }
    }

    GlobalShortcut {
        name: "theme_switcher"
        onPressed: {
            root.revealed = !root.revealed
            if (root.revealed) {
                root.selectedIndex = 0
                mainContent.scale = 0.96
                mainContent.opacity = 0
                entranceAnim.restart()
            }
        }
    }

    HyprlandFocusGrab {
        id: focusGrab
        active: root.revealed
        windows: [osdWindow]
        onCleared: root.revealed = false
    }

    Process {
        id: orchestrator
        running: false
    }

    PanelWindow {
        id: osdWindow
        implicitWidth: 320
        implicitHeight: mainContent.height
        visible: root.revealed
        color: "transparent"
        
        anchors.top: false
        anchors.bottom: false
        anchors.left: false
        anchors.right: false

        WlrLayershell.namespace: "theme-osd"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: root.revealed ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

        FocusScope {
            id: inputScope
            anchors.fill: parent
            focus: true 
            onVisibleChanged: { if (visible) forceActiveFocus() }

            Keys.onUpPressed:   if (root.selectedIndex > 0) root.selectedIndex--
            Keys.onDownPressed: if (root.selectedIndex < themeModel.count - 1) root.selectedIndex++
            Keys.onEscapePressed: root.revealed = false
            Keys.onReturnPressed: applyTheme()
            Keys.onEnterPressed:  applyTheme()

            function applyTheme() {
                // Hide the OSD instantly so we get a clean screenshot of the desktop
                root.revealed = false
                
                const tTheme = themeModel.get(root.selectedIndex).name
                
                // Launch Transition.qml completely detached
                orchestrator.command = [
                    "bash", "-c", 
                    "TARGET_THEME='" + tTheme + "' quickshell -p ~/.config/quickshell/shader-transition/Transition.qml > /tmp/transition.log 2>&1 & disown"
                ]
                
                orchestrator.running = true
            }

            Rectangle {
                id: mainContent
                width: parent.width
                height: layoutColumn.implicitHeight + 32 
                radius: 16
                color: Qt.alpha(Theme.background, 0.95)
                border.width: 1
                border.color: Theme.borderInactive
                
                ParallelAnimation {
                    id: entranceAnim
                    NumberAnimation { target: mainContent; property: "scale"; to: 1.0; duration: 300; easing.type: Easing.OutExpo }
                    NumberAnimation { target: mainContent; property: "opacity"; to: 1.0; duration: 200; easing.type: Easing.OutQuad }
                }

                Column {
                    id: layoutColumn
                    anchors.centerIn: parent
                    width: parent.width - 32
                    spacing: 12
                    Text {
                        text: "SELECT THEME"
                        color: Theme.textSecondary
                        font.pixelSize: 10
                        font.letterSpacing: 2
                        font.bold: true
                        opacity: 0.6
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Column {
                        width: parent.width
                        spacing: 6
                        Repeater {
                            model: themeModel
                            delegate: Rectangle {
                                width: parent.width
                                height: 44 
                                radius: 10
                                property bool isSelected: index === root.selectedIndex
                                color: isSelected ? Qt.alpha(Theme.textPrimary, 0.05) : "transparent"
                                border.width: 2.3
                                border.color: isSelected ? Theme.borderActive : "transparent"
                                Text {
                                    text: label
                                    anchors.centerIn: parent
                                    font.pixelSize: 15
                                    font.weight: isSelected ? Font.DemiBold : Font.Medium
                                    color: isSelected ? Theme.textPrimary : Theme.textSecondary
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
