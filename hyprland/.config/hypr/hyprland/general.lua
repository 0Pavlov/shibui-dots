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
        focus_on_activate = true,
        --render_unfocused_fps = 60
    },

    binds = {
        scroll_event_delay = 0,
        hide_special_on_workspace_change = true
    },

    cursor = {
        zoom_factor = 1,
        zoom_rigid = false,
        hotspot_padding = 1
    },
})
