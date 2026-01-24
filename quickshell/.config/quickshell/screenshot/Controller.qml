pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root
    
    // Set to TRUE for debugging (opens immediately)
    // Set to FALSE when you are done debugging and want to use the keybind
    property bool isOpen: true

    IpcHandler {
        target: "screenshot"
        function open() { root.isOpen = true; }
        function close() { root.isOpen = false; }
        function toggle() { root.isOpen = !root.isOpen; }
    }

    LazyLoader {
        active: root.isOpen
        Overlay {
            controller: root
        }
    }
}
