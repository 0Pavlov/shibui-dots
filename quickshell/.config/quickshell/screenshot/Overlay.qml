pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: root
    required property var controller
    
    screen: Quickshell.screens[0]

    anchors { top: true; bottom: true; left: true; right: true }
    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    visible: false

    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "shell:screenshot"

    // --- SHARED CONFIGURATION ---
    // This object holds the single source of truth for your geometry
    QtObject {
        id: config
        
        // Visual Style
        readonly property int frameSize: 12
        readonly property int cornerExt: 24
        
        // Capture Logic
        // A positive padding shrinks the capture area slightly INWARDS
        // to ensure we don't accidentally capture the rope tips or frame border.
        readonly property int capturePadding: 2 
    }

    // --- 1. The Freeze-Frame Capture ---
    Process {
        id: grabber
        command: ["grim", "-o", root.screen.name, "/tmp/qs_rope_temp.png"]
        onExited: (exitCode) => {
            if (exitCode === 0) {
                preview.source = "";
                preview.source = "file:///tmp/qs_rope_temp.png";
                root.visible = true;
                root.isSelecting = false;
                uiLayer.focus = true;
            } else {
                root.visible = true;
            }
        }
    }

    Component.onCompleted: { if (controller.isOpen) grabber.running = true; }

    Connections {
        target: controller
        function onIsOpenChanged() {
            if (controller.isOpen) {
                root.visible = false;
                grabber.running = true;
            } else {
                root.visible = false;
            }
        }
    }

    // --- 2. Background ---
    Image {
        id: preview
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        cache: false
    }

    // --- 3. Output Process ---
    Process {
        id: cmd
        running: false
        onExited: (exitCode) => {
             if (exitCode === 0) notifyCmd.running = true;
             root.controller.isOpen = false;
        }
    }

    Process {
        id: notifyCmd
        command: ["notify-send", "Screenshot", "Copied to clipboard"]
        running: false
    }

    // --- 4. UI Layer ---
    property real originX: 0
    property real originY: 0
    property real selLeft: 0
    property real selTop: 0
    property real selRight: 0
    property real selBottom: 0
    property bool isSelecting: false

    Item {
        id: uiLayer
        anchors.fill: parent
        focus: true

        Keys.onEscapePressed: root.controller.isOpen = false

        Keys.onReturnPressed: () => {
            if (root.selRight > root.selLeft && root.selBottom > root.selTop) {
                // HIDE ROPES: We hide the ropes manually because they physically 
                // touch the selection line. The frame is safe, but ropes are not.
                ropesContainer.visible = false;

                // MATH: Use the shared config to calculate the safe capture zone
                // We add padding to X/Y and subtract padding*2 from Width/Height
                // This ensures we capture strictly INSIDE the transparent hole.
                const x = Math.floor(root.selLeft) + config.capturePadding;
                const y = Math.floor(root.selTop) + config.capturePadding;
                const w = Math.ceil(root.selRight - root.selLeft) - (config.capturePadding * 2);
                const h = Math.ceil(root.selBottom - root.selTop) - (config.capturePadding * 2);

                if (w > 0 && h > 0) {
                    cmd.command = ["sh", "-c", `grim -g "${x},${y} ${w}x${h}" - | wl-copy`];
                    cmd.running = true;
                }
            }
        }

        Canvas {
            id: canvas
            anchors.fill: parent
            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();
                ctx.fillStyle = "#66000000";
                ctx.fillRect(0, 0, root.width, root.height);

                if (root.selRight > root.selLeft && root.selBottom > root.selTop) {
                    // Use the Shared Config Variables
                    const fSize = config.frameSize;
                    const cExt = config.cornerExt;

                    // 1. Clear the "Hole" (The exact selection area)
                    ctx.clearRect(root.selLeft, root.selTop, root.selRight - root.selLeft, root.selBottom - root.selTop);

                    // 2. Draw Frame OUTSIDE the hole
                    // Notice we subtract frameSize/cornerExt from Left/Top, 
                    // ensuring the frame never enters the cleared rect.
                    ctx.fillStyle = "#8D6E63";
                    
                    // Top Bar
                    ctx.fillRect(root.selLeft - cExt, root.selTop - fSize, (root.selRight - root.selLeft) + cExt*2, fSize);
                    // Bottom Bar
                    ctx.fillRect(root.selLeft - cExt, root.selBottom, (root.selRight - root.selLeft) + cExt*2, fSize);
                    // Left Bar
                    ctx.fillRect(root.selLeft - fSize, root.selTop - cExt, fSize, (root.selBottom - root.selTop) + cExt*2);
                    // Right Bar
                    ctx.fillRect(root.selRight, root.selTop - cExt, fSize, (root.selBottom - root.selTop) + cExt*2);
                }
            }
        }

        // Group ropes to toggle visibility easily
        Item {
            id: ropesContainer
            anchors.fill: parent
            visible: root.isSelecting

            Rope { anchors.fill: parent; start: Qt.vector2d(0, 0); end: Qt.vector2d(root.selLeft, root.selTop) }
            Rope { anchors.fill: parent; start: Qt.vector2d(root.width, 0); end: Qt.vector2d(root.selRight, root.selTop) }
            Rope { anchors.fill: parent; start: Qt.vector2d(root.width, root.height); end: Qt.vector2d(root.selRight, root.selBottom) }
            Rope { anchors.fill: parent; start: Qt.vector2d(0, root.height); end: Qt.vector2d(root.selLeft, root.selBottom) }

            RopeTie { x: root.selLeft - width/2; y: root.selTop - height/2 }
            RopeTie { x: root.selRight - width/2; y: root.selTop - height/2 }
            RopeTie { x: root.selRight - width/2; y: root.selBottom - height/2 }
            RopeTie { x: root.selLeft - width/2; y: root.selBottom - height/2 }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.CrossCursor
            onPressed: (e) => {
                root.isSelecting = true;
                ropesContainer.visible = true; // Show ropes again if we start a new drag
                root.originX = e.x; root.originY = e.y;
                root.selLeft = e.x; root.selTop = e.y; root.selRight = e.x; root.selBottom = e.y;
                canvas.requestPaint();
            }
            onPositionChanged: (e) => {
                if (!pressed) return;
                root.selLeft = Math.min(root.originX, e.x);
                root.selRight = Math.max(root.originX, e.x);
                root.selTop = Math.min(root.originY, e.y);
                root.selBottom = Math.max(root.originY, e.y);
                canvas.requestPaint();
            }
        }
    }
}
