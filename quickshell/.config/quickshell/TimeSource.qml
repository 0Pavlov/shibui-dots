// "pragma Singleton" tells QML that this object should only be created ONCE,
// no matter how many times it is referenced
pragma Singleton

import QtQuick
import Quickshell

Singleton {
    // -------------------------------------------------------------------------
    // PUBLIC PROPERTIES
    // -------------------------------------------------------------------------
    
    // This property holds the final formatted string (e.g., "04:30")
    // The logic inside the binding {} updates automatically when `clock.time` changes
    readonly property string time: {
        // Get current time from the SystemClock object below
        const now = clock.date.getTime();

        // Add custom 8-hour offset (8 hours * 60 mins * 60 secs * 1000 ms)
        const offset = 8 * 60 * 60 * 1000;
        const targetDate = new Date(now + offset);

        // Format the time to HH:mm AP (e.g. 04:30 PM)
        const formatted = Qt.formatTime(targetDate, "hh:mm AP");

        // Split by space to remove AM/PM if desired, taking the first part
        return formatted.split(" ")[0];
    }

    // -------------------------------------------------------------------------
    // INTERNAL OBJECTS
    // -------------------------------------------------------------------------

    // The Quickshell service that provides the system time
    SystemClock {
        id: clock
        // Precision set to Minutes saves CPU cycles since we don't show seconds
        precision: SystemClock.Minutes
    }
}
