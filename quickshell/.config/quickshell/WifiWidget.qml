import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io

Rectangle {
    id: root

    // --- STATE ---
    property bool isWifiEnabled: false
    property bool isExpanded: false
    property string currentSsid: "Disconnected"
    
    // Connection State Handling
    property string connectingSsid: ""      // The SSID currently being attempted
    property bool connectionError: false    // If the last attempt failed
    property bool isScanning: false         // To show global loading feedback

    // Size and Appearance
    width: parent.width
    height: isExpanded ? 280 : 56 // Increased slightly to accommodate feedback
    radius: 12
    clip: true

    Behavior on height {
        NumberAnimation { duration: 250; easing.type: Easing.OutQuart }
    }

    color: isWifiEnabled ? Qt.alpha(Theme.borderActive, 0.05) : Qt.alpha(Theme.textPrimary, 0.03)
    border.width: 1
    border.color: isWifiEnabled ? Qt.alpha(Theme.borderActive, 0.4) : Qt.alpha(Theme.borderInactive, 0.5)

    Behavior on color { ColorAnimation { duration: 200 } }
    Behavior on border.color { ColorAnimation { duration: 200 } }

    // --- HELPERS ---

    function hasActivePasswordInput() {
        for (var i = 0; i < networksModel.count; i++) {
            if (networksModel.get(i).showInput) return true;
        }
        return false;
    }

    function shellEscape(str) {
        return "'" + str.replace(/'/g, "'\\''") + "'";
    }

    // --- SYSTEM LOGIC ---

    // Wifi Radio Check
    Process {
        command: ["nmcli", "radio", "wifi"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                let line = String(data).trim()
                if (line.length > 0) root.isWifiEnabled = (line === "enabled")
            }
        }
    }

    // Background Poller
    // Checks status even when collapsed so the label is always correct.
    // We check for active connections of type wifi.
    Process {
        id: statusProcess
        command: ["nmcli", "-t", "-f", "TYPE,NAME", "connection", "show", "--active"]
        stdout: SplitParser {
            onRead: data => {
                let line = String(data).trim()
                // Output format: 802-11-wireless:SSID_Name
                if (line.startsWith("802-11-wireless:")) {
                    root.currentSsid = line.substring(16) // Remove prefix
                }
            }
        }
        // Reset to "Disconnected" before parsing; if the parse finds nothing, it stays disconnected
        onRunningChanged: {
            if (running) root.currentSsid = "Disconnected"
        }
    }

    Timer {
        interval: 5000; running: true; repeat: true
        onTriggered: {
            // Only poll status if we aren't actively scanning or connecting
            if (!root.isExpanded && !scanProcess.running && connectingSsid === "") {
                statusProcess.running = true
            }
        }
    }

    // Network Scanner
    ListModel { id: networksModel }
    
    // We buffer results in a JS array to allow sorting before display
    property var _scanBuffer: []

    Process {
        id: scanProcess
        // command: IN-USE, SIGNAL, SECURITY, SSID
        command: ["nmcli", "-t", "-f", "IN-USE,SIGNAL,SECURITY,SSID", "dev", "wifi"]
        
        onRunningChanged: {
            root.isScanning = running
            if (running) {
                root._scanBuffer = [] // Clear buffer on start
            }
        }

        onExited: (exitCode) => {
            if (exitCode === 0) {
                // Process finished: Sort and Populate
                // Sort Connected first, then Alphabetical
                root._scanBuffer.sort(function(a, b) {
                    // Connected ('inUse') goes first
                    if (a.inUse && !b.inUse) return -1;
                    if (!a.inUse && b.inUse) return 1;
                    
                    // Alphabetical by SSID
                    return a.ssid.localeCompare(b.ssid);
                });

                networksModel.clear();
                
                // If buffer is empty but wifi is on, it might be a glitch, wait for next scan
                for (var i = 0; i < root._scanBuffer.length; i++) {
                    networksModel.append(root._scanBuffer[i]);
                }
                
                // If we are connected, ensure currentSsid is accurate immediately
                if (root._scanBuffer.length > 0 && root._scanBuffer[0].inUse) {
                    root.currentSsid = root._scanBuffer[0].ssid;
                }
            } else {
                // Scan failed – retry after a short delay (if still enabled and expanded)
                retryScanTimer.start();
            }
        }

        stdout: SplitParser {
            onRead: data => {
                if (root.hasActivePasswordInput()) return; // Don't interrupt typing

                let line = String(data)
                
                // Parse Manual (colon safe)
                let p1 = line.indexOf(":")
                let p2 = line.indexOf(":", p1 + 1)
                let p3 = line.indexOf(":", p2 + 1)

                if (p1 === -1 || p2 === -1 || p3 === -1) return

                let inUseStr = line.substring(0, p1)
                let signalStr = line.substring(p1 + 1, p2)
                let secStr = line.substring(p2 + 1, p3)
                let ssidStr = line.substring(p3 + 1).trim()

                if (ssidStr === "") return // skip hidden

                // Deduplicate in buffer
                let exists = false
                for (let i = 0; i < root._scanBuffer.length; i++) {
                    if (root._scanBuffer[i].ssid === ssidStr) {
                        exists = true; 
                        break;
                    }
                }

                if (!exists) {
                    root._scanBuffer.push({
                        inUse: (inUseStr === "*"),
                        signal: parseInt(signalStr),
                        security: secStr,
                        ssid: ssidStr,
                        showInput: false // Controls visibility of Password OR Disconnect
                    })
                }
            }
        }
    }

    // Retry timer for failed scans
    Timer {
        id: retryScanTimer
        interval: 2000
        onTriggered: {
            if (root.isWifiEnabled && root.isExpanded && !scanProcess.running) {
                scanProcess.running = true;
            }
        }
    }

    // Connection Process
    Process {
        id: connectProcess
        onExited: exitCode => {
            if (exitCode !== 0) {
                // Wrong password / Failure feedback
                root.connectionError = true
            } else {
                root.connectionError = false
                // Success: Refresh list
                networksModel.clear()
                scanProcess.running = true
                statusProcess.running = true
            }
            root.connectingSsid = "" // Stop spinner
        }
    }

    // Disconnect Process
    Process {
        id: disconnectProcess
        onExited: {
            networksModel.clear()
            scanProcess.running = true
            statusProcess.running = true
        }
    }
    
    // Power Toggle Process
    Process { id: powerProcess }

    // Auto-rescan Timer (only when expanded)
    Timer {
        interval: 10000; running: root.isExpanded && !scanProcess.running; repeat: true
        onTriggered: {
            if (root.hasActivePasswordInput() || root.connectingSsid !== "") return;
            scanProcess.running = true;
        }
    }

    // Delayed scan start after power-on (gives hardware time to come up)
    Timer {
        id: delayedPowerOnScanTimer
        interval: 800
        onTriggered: {
            if (root.isWifiEnabled && root.isExpanded && !scanProcess.running) {
                scanProcess.running = true;
            }
        }
    }

    // --- UI LAYOUT ---
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // HEADER
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 56

            RowLayout {
                anchors.fill: parent
                spacing: 0

                // Main Click Area (Expand)
                Rectangle {
                    Layout.fillWidth: true; Layout.fillHeight: true
                    color: headerHover.containsMouse ? Qt.alpha(Theme.textPrimary, 0.05) : "transparent"
                    radius: 12

                    MouseArea {
                        id: headerHover
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if (!root.isWifiEnabled) return
                            root.isExpanded = !root.isExpanded
                            if (root.isExpanded && !scanProcess.running) {
                                scanProcess.running = true
                            }
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12

                        // Wifi Icon
                        Rectangle {
                            width: 32; height: 32; radius: 8
                            color: root.isWifiEnabled ? Qt.alpha(Theme.borderActive, 0.15) : "transparent"
                            Text {
                                anchors.centerIn: parent
                                text: root.isWifiEnabled ? "󰖩" : "󰖪"
                                color: root.isWifiEnabled ? Theme.borderActive : Theme.textSecondary
                                font.pixelSize: 18
                            }
                        }

                        Column {
                            Layout.fillWidth: true
                            Text {
                                text: "Wi-Fi"
                                color: Theme.textPrimary
                                font.pixelSize: 14
                                font.weight: Font.DemiBold
                            }
                            Text {
                                text: root.isWifiEnabled ? root.currentSsid : "Turned off"
                                color: Theme.textSecondary
                                font.pixelSize: 11
                            }
                        }
                        
                        // Expand Arrow
                        Text {
                            text: root.isExpanded ? "󰅀" : "󰅂"
                            color: Theme.textSecondary
                            font.pixelSize: 18
                            opacity: root.isWifiEnabled ? 1 : 0.3
                        }
                    }
                }

                // Divider
                Rectangle {
                    width: 1; Layout.fillHeight: true
                    Layout.topMargin: 12; Layout.bottomMargin: 12
                    color: Qt.alpha(Theme.borderInactive, 0.5)
                }

                // Power Toggle
                Rectangle {
                    Layout.preferredWidth: 56; Layout.fillHeight: true
                    color: toggleHover.containsMouse ? Qt.alpha(Theme.textPrimary, 0.05) : "transparent"
                    radius: 12

                    MouseArea {
                        id: toggleHover
                        anchors.fill: parent
                        hoverEnabled: false
                        onClicked: {
                            root.isWifiEnabled = !root.isWifiEnabled
                            if (!root.isWifiEnabled) {
                                root.isExpanded = false
                                scanProcess.running = false       // stop any ongoing scan
                                networksModel.clear()             // optional: clear list immediately
                            } else {
                                // Wi‑Fi turned on – start delayed scan if expanded
                                if (root.isExpanded) {
                                    delayedPowerOnScanTimer.start();
                                }
                            }
                            powerProcess.command = ["nmcli", "radio", "wifi", root.isWifiEnabled ? "on" : "off"]
                            powerProcess.running = true
                        }
                    }

                    Rectangle {
                        anchors.centerIn: parent
                        width: 32; height: 18; radius: 9
                        color: root.isWifiEnabled ? Theme.borderActive : Qt.alpha(Theme.textPrimary, 0.2)
                        Rectangle {
                            width: 12; height: 12; radius: 6
                            color: Theme.background
                            y: 3
                            x: root.isWifiEnabled ? parent.width - width - 3 : 3
                            Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
                        }
                    }
                }
            }
        }

        // EXPANDED LIST AREA
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: root.isExpanded && root.isWifiEnabled
            clip: true

            // === SCANNING FEEDBACK ===
            // Overlay shown whenever scanning is in progress, regardless of existing networks.
            // It dims the list, shows a spinner, and blocks interactions.
            Rectangle {
                anchors.fill: parent
                color: Qt.alpha(Theme.background, 0.7) // semi-transparent dim
                visible: root.isScanning
                z: 10

                // Block mouse events so the list cannot be clicked while scanning
                MouseArea {
                    anchors.fill: parent
                    onClicked: {} // consume clicks
                }

                Row {
                    anchors.centerIn: parent
                    spacing: 8
                    
                    Text {
                        text: "󰑐" // Loading icon
                        color: Theme.textPrimary
                        font.pixelSize: 20
                        RotationAnimation on rotation {
                            from: 0; to: 360; duration: 1000; loops: Animation.Infinite
                        }
                    }
                    Text {
                        text: "Scanning..."
                        color: Theme.textPrimary
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            ScrollView {
                anchors.fill: parent
                anchors.topMargin: 4
                anchors.bottomMargin: 12
                contentWidth: width

                Column {
                    width: parent.width
                    spacing: 4

                    Repeater {
                        model: networksModel
                        delegate: Rectangle {
                            id: networkDelegate
                            width: parent.width - 24
                            anchors.horizontalCenter: parent.horizontalCenter
                            
                            // Height logic: Base 40 + Input/Action area if showInput is true
                            height: showInput ? 80 : 40
                            radius: 8
                            color: listHover.containsMouse ? Qt.alpha(Theme.textPrimary, 0.05) : "transparent"
                            
                            Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }

                            // Connection / Disconnect Functions
                            function connectNetwork() {
                                root.connectionError = false
                                root.connectingSsid = model.ssid
                                
                                let escSsid = root.shellEscape(model.ssid)
                                let escPass = pwInput.text !== "" ? root.shellEscape(pwInput.text) : ""
                                
                                let cmd = `nmcli connection delete ${escSsid} 2>/dev/null; ` +
                                          `nmcli connection add type wifi con-name ${escSsid} ifname wlan0 ssid ${escSsid}`
                                
                                if (pwInput.text !== "") {
                                    cmd += ` wifi-sec.key-mgmt wpa-psk wifi-sec.psk ${escPass}`
                                }
                                cmd += ` && nmcli connection up ${escSsid}`
                                
                                connectProcess.command = ["sh", "-c", cmd]
                                connectProcess.running = true
                                pwInput.text = ""
                            }

                            function disconnectNetwork() {
                                let escSsid = root.shellEscape(model.ssid)
                                // Requirement 1: Down and Delete
                                let cmd = `nmcli connection down ${escSsid} && nmcli connection delete ${escSsid}`
                                disconnectProcess.command = ["sh", "-c", cmd]
                                disconnectProcess.running = true
                            }

                            MouseArea {
                                id: listHover
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    // Reset error state on new interaction
                                    root.connectionError = false 

                                    // Toggle input visibility logic
                                    let wasShown = showInput
                                    
                                    // Close others
                                    for(let i=0; i<networksModel.count; i++) {
                                        networksModel.setProperty(i, "showInput", false)
                                    }

                                    if (!wasShown) {
                                        scanProcess.running = false // Pause scan
                                        
                                        // If secured or if it's the connected network, show input area
                                        if (inUse || (security !== "" && security !== "--")) {
                                            networksModel.setProperty(index, "showInput", true)
                                        } else {
                                            // Open network, just connect
                                            connectNetwork()
                                        }
                                    }
                                }
                            }

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 8

                                // Top Row: Icon + Name + Lock
                                RowLayout {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 16 // vertically centered within top 40px
                                    spacing: 12

                                    Text {
                                        text: inUse ? "󰖩" : (signal > 75 ? "󰤨" : (signal > 50 ? "󰤥" : "󰤢"))
                                        color: inUse ? Theme.borderActive : Theme.textPrimary
                                        font.pixelSize: 16
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: ssid
                                        color: inUse ? Theme.borderActive : Theme.textPrimary
                                        font.pixelSize: 13
                                        font.weight: inUse ? Font.DemiBold : Font.Normal
                                        elide: Text.ElideRight
                                    }

                                    // Spinner for this specific network
                                    Text {
                                        visible: root.connectingSsid === ssid
                                        text: "󰑐"
                                        color: Theme.borderActive
                                        font.pixelSize: 14
                                        RotationAnimation on rotation {
                                            from: 0; to: 360; duration: 1000; loops: Animation.Infinite; running: visible
                                        }
                                    }

                                    Text {
                                        visible: security !== "" && security !== "--" && !inUse
                                        text: "󰌾"
                                        color: Theme.textSecondary
                                        font.pixelSize: 12
                                    }
                                }

                                // Bottom Row: Input Field OR Disconnect Button
                                Item {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    visible: showInput

                                    // CASE 1: Disconnect UI
                                    RowLayout {
                                        anchors.fill: parent
                                        visible: inUse
                                        
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            radius: 6
                                            color: Qt.alpha(Theme.error, 0.15)
                                            border.width: 1
                                            border.color: Qt.alpha(Theme.error, 0.3)

                                            Text {
                                                anchors.centerIn: parent
                                                text: "Disconnect & Forget"
                                                color: Theme.error
                                                font.pixelSize: 12
                                                font.weight: Font.DemiBold
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: disconnectNetwork()
                                            }
                                        }
                                    }

                                    // CASE 2: Password UI
                                    RowLayout {
                                        anchors.fill: parent
                                        visible: !inUse
                                        spacing: 8

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            radius: 6
                                            color: Qt.alpha(Theme.background, 0.8)
                                            // Visual Error Feedback
                                            border.width: root.connectionError && root.connectingSsid === "" ? 1 : 1
                                            border.color: root.connectionError && root.connectingSsid === "" ? Theme.error : (pwInput.activeFocus ? Theme.borderActive : Theme.borderInactive)

                                            TextInput {
                                                id: pwInput
                                                anchors.fill: parent
                                                anchors.leftMargin: 8; anchors.rightMargin: 8
                                                verticalAlignment: TextInput.AlignVCenter
                                                color: Theme.textPrimary
                                                font.pixelSize: 12
                                                echoMode: TextInput.Password
                                                clip: true
                                                onAccepted: connectNetwork()
                                                
                                                // Placeholder text for error
                                                Text {
                                                    visible: parent.text === "" && root.connectionError && root.connectingSsid === ""
                                                    text: "Failed. Try again."
                                                    color: Theme.error
                                                    font.pixelSize: 11
                                                    anchors.centerIn: parent
                                                }
                                            }
                                        }

                                        Rectangle {
                                            width: 60
                                            Layout.fillHeight: true
                                            radius: 6
                                            color: root.connectingSsid === ssid ? Theme.borderInactive : Theme.borderActive

                                            // Spinner inside button if connecting
                                            Item {
                                                anchors.centerIn: parent
                                                width: 16; height: 16
                                                visible: root.connectingSsid === ssid
                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "󰑐"
                                                    color: Theme.background
                                                    RotationAnimation on rotation {
                                                        from: 0; to: 360; duration: 1000; loops: Animation.Infinite; running: parent.visible
                                                    }
                                                }
                                            }

                                            Text {
                                                anchors.centerIn: parent
                                                text: "Join"
                                                color: Theme.background
                                                font.pixelSize: 12
                                                font.weight: Font.DemiBold
                                                visible: root.connectingSsid !== ssid
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                enabled: root.connectingSsid === ""
                                                onClicked: connectNetwork()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
