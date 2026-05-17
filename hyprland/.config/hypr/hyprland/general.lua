-- MONITOR CONFIG (fallback)
hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = 1
})

hl.config({
    general = {
        -- Gaps and border
        gaps_in = 4,
        gaps_out = 5,
        gaps_workspaces = 50,
        border_size = 2,
        resize_on_border = true,
        no_focus_fallback = true,
        allow_tearing = true, -- This just allows the `immediate` window rule to work

        -- Snap
        snap = {
            enabled = true,
            window_gap = 4,
            monitor_gap = 5,
            respect_gaps = true
        }
    },

    dwindle = {
        preserve_split = true,
        smart_split = false,
        smart_resizing = false
    },

    decoration = {
        rounding = 18,

        blur = {
            enabled = true,
            xray = true,
            special = false,
            new_optimizations = true,
            size = 10,
            passes = 3,
            brightness = 1,
            noise = 0.05,
            contrast = 0.89,
            vibrancy = 0.5,
            vibrancy_darkness = 0.5,
            popups = false,
            popups_ignorealpha = 0.6,
            input_methods = true,
            input_methods_ignorealpha = 0.8
        },

        shadow = {
            enabled = true,
            range = 30,
            offset = { 0, 2 },
            render_power = 4
        },

        -- Dim
        dim_inactive = true,
        dim_strength = 0.025,
        dim_special = 0.07
    },

    animations = {
        enabled = true,
        -- Curves
        bezier = {
            { name = "expressiveFastSpatial", points = { 0.42, 1.67, 0.21, 0.90 } },
            { name = "expressiveSlowSpatial", points = { 0.39, 1.29, 0.35, 0.98 } },
            { name = "expressiveDefaultSpatial", points = { 0.38, 1.21, 0.22, 1.00 } },
            { name = "emphasizedDecel", points = { 0.05, 0.7, 0.1, 1 } },
            { name = "emphasizedAccel", points = { 0.3, 0, 0.8, 0.15 } },
            { name = "standardDecel", points = { 0, 0, 0, 1 } },
            { name = "menu_decel", points = { 0.1, 1, 0, 1 } },
            { name = "menu_accel", points = { 0.52, 0.03, 0.72, 0.08 } },
            { name = "stall", points = { 1, -0.1, 0.7, 0.85 } }
        },

        -- windows
        animation = {
            { name = "windowsIn", style = "popin 80%", duration = 1, curve = "emphasizedDecel", style_duration = 3 },
            { name = "fadeIn", duration = 1, curve = "emphasizedDecel", style_duration = 3 },
            { name = "windowsOut", style = "popin 90%", duration = 1, curve = "emphasizedDecel", style_duration = 2 },
            { name = "fadeOut", duration = 1, curve = "emphasizedDecel", style_duration = 2 },
            { name = "windowsMove", style = "slide", duration = 1, curve = "emphasizedDecel", style_duration = 3 },
            { name = "border", duration = 1, curve = "emphasizedDecel", style_duration = 10 },

            -- layers
            { name = "layersIn", style = "popin 93%", duration = 1, curve = "emphasizedDecel", style_duration = 2.7 },
            { name = "layersOut", style = "popin 94%", duration = 1, curve = "menu_accel", style_duration = 2.4 },

            -- fade
            { name = "fadeLayersIn", duration = 1, curve = "menu_decel", style_duration = 0.5 },
            { name = "fadeLayersOut", duration = 1, curve = "stall", style_duration = 2.7 },

            -- workspaces
            { name = "workspaces", style = "slide", duration = 1, curve = "menu_decel", style_duration = 7 },

            -- specialWorkspace
            { name = "specialWorkspaceIn", style = "slidevert", duration = 1, curve = "emphasizedDecel", style_duration = 2.8 },
            { name = "specialWorkspaceOut", style = "slidevert", duration = 1, curve = "emphasizedAccel", style_duration = 1.2 }
        }
    },

    input = {
        kb_layout = "us,ru",
        numlock_by_default = true,
        repeat_delay = 250,
        repeat_rate = 35,
        follow_mouse = 1,
        off_window_axis_events = 2,

        touchpad = {
            natural_scroll = true,
            disable_while_typing = true,
            clickfinger_behavior = true,
            scroll_factor = 0.7
        }
    },

    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        vrr = 1,
        mouse_move_enables_dpms = true,
        key_press_enables_dpms = true,
        animate_manual_resizes = false,
        animate_mouse_windowdragging = false,
        enable_swallow = false,
        swallow_regex = "(foot|kitty|allacritty|Alacritty)",
        allow_session_lock_restore = true,
        session_lock_xray = true,
        initial_workspace_tracking = false,
        focus_on_activate = true
    },

    binds = {
        scroll_event_delay = 0,
        hide_special_on_workspace_change = true
    },

    cursor = {
        zoom_factor = 1,
        zoom_rigid = false,
        hotspot_padding = 1
    }
})
