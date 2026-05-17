-- Load additional configuration modules (replaces source=)
require("hyprland/general")
require("hyprland/colors")
require("hyprland/keybinds")
require("hyprland/execs")
require("hyprland/amneziavpn")

-- nwg-displays support
require("workspaces")
require("monitors")

-- NVIDIA ESSENTIALS (replaces env =)
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")

-- Cursor and icons (replaces env =)
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Execute on startup (replaces exec-once =)
hl.on("hyprland.start", function()
    hl.exec_cmd("hyprctl setcursor Bibata-Modern-Classic 24")
end)

-- Master layout (replaces master {})
hl.config({
    master = {
        new_status = "master"
    }
})

-- Gestures (replaces gesture = 3, horizontal, workspace)
hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})

-- Per-device config (replaces device {})
hl.device({
    name = "epic-mouse-v1",
    sensitivity = -0.5
})
