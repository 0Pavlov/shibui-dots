import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Scope {
    id: root
    property string phase: "init"
    property int screensReadyCount: 0
    property int transitionsFinishedCount: 0
    property int totalScreens: Quickshell.screens.length
    property double cacheBuster: Date.now()
    
    // This argument should be passed by the caller
    property string targetTheme: Quickshell.env("TARGET_THEME") || ""

    signal broadcastLoadScreenshots()
    signal broadcastStartTransition()

    // START HERE: Wait a fraction of a second before doing anything
    Component.onCompleted: beginPhase("waitForOSDHide")

    function beginPhase(newPhase) {
        root.phase = newPhase
        console.log("[Transition] ->", newPhase)

        switch (newPhase) {
            case "waitForOSDHide":
                osdHideDelayTimer.restart()
                break

            case "takingScreenshots":
                screenshotProcess.running = true
                break

            case "loadingScreenshots":
                screensReadyCount = 0
                root.broadcastLoadScreenshots()
                break

            case "overlaySettle":
                waylandSettleTimer.restart()
                break

            case "runningTheme":
                themeProcess.running = true
                break

            case "runningTransition":
                transitionsFinishedCount = 0
                root.broadcastStartTransition()
                break

            case "done":
                Qt.quit()
                break
        }
    }

    // --- TIMERS ---
    
    Timer {
        id: osdHideDelayTimer
        interval: 150 // Gives Hyprland a couple of frames to completely clear the OSD from the screen
        // It works for mine OSD which I use to switch themes
        // Change it for yours
        onTriggered: root.beginPhase("takingScreenshots")
    }

    Timer {
        id: waylandSettleTimer
        interval: 350
        onTriggered: root.beginPhase("runningTheme")
    }

    // --- PROCESSES ---

    Process {
        id: screenshotProcess
        running: false
        command: ["bash", "-c", "for m in $(hyprctl monitors -j | jq -r '.[].name'); do grim -o \"$m\" \"/tmp/quickshell_bg_$m.png\" & done; wait"]
        onExited: root.beginPhase("loadingScreenshots")
    }

    Process {
        id: themeProcess
        running: false
        // There you should run your theme switcher program or any script you want
        // It should be performed fully by design of this module
        // And only then it should proceed to transition animation
        // You also can use your theme name to pass into your theme switcher if you need
        command: ["bash", "-c", "python3 ~/.config/theme-switcher/theme_switcher.py " + root.targetTheme]
        onExited: root.beginPhase("runningTransition")
    }

    // --- CALLBACKS ---

    function reportScreenReady() {
        if (root.phase !== "loadingScreenshots") return
        screensReadyCount++
        if (screensReadyCount === root.totalScreens) root.beginPhase("overlaySettle")
    }

    function reportTransitionFinished() {
        if (root.phase !== "runningTransition") return
        transitionsFinishedCount++
        if (transitionsFinishedCount === root.totalScreens) root.beginPhase("done")
    }

    // --- WINDOWS ---

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: transitionWindow
            property var modelData
            screen: modelData
            
            WlrLayershell.namespace: "shader-background"
            WlrLayershell.layer: WlrLayer.Overlay 
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            exclusionMode: ExclusionMode.Ignore
            
            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            color: "transparent"
            visible: true

            Connections {
                target: root
                function onBroadcastLoadScreenshots() {
                    screenshotImage.source = "file:///tmp/quickshell_bg_" + modelData.name + ".png?t=" + root.cacheBuster
                }
                function onBroadcastStartTransition() {
                    transitionAnim.restart()
                }
            }

            Image {
                id: screenshotImage
                visible: false
                onStatusChanged: {
                    if (status === Image.Ready) root.reportScreenReady()
                }
            }

            ShaderEffect {
                id: shader
                anchors.fill: parent
                property real progress: 0.0
                property Image sourceImage: screenshotImage
                fragmentShader: "shader.frag.qsb"
            }

            NumberAnimation {
                id: transitionAnim
                target: shader
                property: "progress"
                from: 0.0
                to: 1.0
                // The full duration of the transition is set there (not in the shader)
                duration: 1000
                easing.type: Easing.InOutQuad
                
                onStopped: root.reportTransitionFinished()
            }
        }
    }
}
