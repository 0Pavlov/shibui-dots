local terminal    = "ghostty"
local browser     = "firefox"
local fileManager = "nautilus"
local obs         = "obs"
local gpu         = "prime-run"
local mainMod     = "SUPER"

-- Exit hyprland
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd(
    "command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit"
))

-- Theme switcher OSD (global shortcut)
hl.bind(mainMod .. " + T", hl.dsp.global("quickshell:theme_switcher"))

-- Change keyboard layout
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("hyprctl switchxkblayout all next"))

-- Screenshot
hl.bind("Print", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | swappy -f -"))

-- Applications
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(gpu .. " " .. terminal))
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd(gpu .. " " .. obs))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))

-- Quickshell
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("qs"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("killall qs"))

-- killactive
local closeWindowBind = hl.bind(mainMod .. " + Q", hl.dsp.window.close())
-- closeWindowBind:set_enabled(false)

-- Floating windows: toggle, resize exact, center
--hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + V", function()
    -- 1. Grab the currently focused window object
    local w = hl.get_active_window()
    if not w then return end

    -- 2. Check its current state
    if w.floating then
        -- If it's ALREADY floating, simply toggle it back into the tiled layout
        hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    else
        -- If it's TILED, we float it, resize it, and center it
        hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
        
        -- Grab the active monitor object to calculate 70% scale locally
        local m = hl.get_active_monitor()
        if m then
            -- Calculate 70% of the active monitor's resolution
            local target_w = math.floor(m.width * 0.7)
            local target_h = math.floor(m.height * 0.7)
            
            -- Apply exact size (relative = false means exact layout pixels)
            hl.dispatch(hl.dsp.window.resize({ x = target_w, y = target_h, relative = false }))
            
            -- Finally, center the window
            hl.dispatch(hl.dsp.window.center())
        end
    end
end)

-- pseudo (dwindle)
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())

-- Move focus
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "d" }))

-- Switch workspaces and move windows
for i = 1, 10 do
    local key = i % 10   -- 10 → 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Mouse bindings
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Multimedia keys
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
        { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
        { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
        { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
        { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),
        { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),
        { locked = true, repeating = true })

-- Playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
