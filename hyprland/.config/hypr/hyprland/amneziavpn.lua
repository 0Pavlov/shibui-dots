-- Run amnezia vpn (remove if isn't installed or you don't have yourusername ALL=(root) NOPASSWRD: /usr/bin/awg-quick up awg0 in your visudo)
hl.on("hyprland.start", function()
    hl.exec_cmd("sudo awg-quick up awg0")
end)
-- Useful commands:
-- Disconnect: sudo awg-quick down awg0
-- Reconnect: sudo awg-quick up awg0
-- Check Status: sudo awg
