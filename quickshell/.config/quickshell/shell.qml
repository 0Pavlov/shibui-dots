import Quickshell
import QtQml

// Scope is a basic container object in Quickshell
// It is used here as the root of the configuration
Scope {
    // Disable 'Config reloaded' popups
    // If there is an error, those popups still will appear
    Connections {
        target: Quickshell

        function onReloadCompleted() {
            Quickshell.inhibitReloadPopup();
        }
    }
    // Load the Bar component defined in Bar.qml
    // Quickshell automatically finds files starting with Capital letters
    // in the same directory
    Bar {}
    // Keyboard layout switch OSD
    KbLayoutOSD {}
    // Theme switcher OSD
    ThemeSwitcherOSD {}
}
