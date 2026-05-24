-- Global switch
hl.config({
    animations = {
        enabled = true,
    }
})

-- ===============================================================================================
-- Curves (bezier)
-- ===============================================================================================
--hl.curve("expressiveFastSpatial",    { type = "bezier", points = { {0.42, 1.67}, {0.21, 0.90} } })
--hl.curve("expressiveSlowSpatial",    { type = "bezier", points = { {0.39, 1.29}, {0.35, 0.98} } })
--hl.curve("expressiveDefaultSpatial", { type = "bezier", points = { {0.38, 1.21}, {0.22, 1.00} } })
hl.curve("emphasizedDecel",          { type = "bezier", points = { {0.05, 0.7},  {0.1,  1.0 } } })
hl.curve("emphasizedAccel",          { type = "bezier", points = { {0.3,  0.0},  {0.8,  0.15} } })
hl.curve("standardDecel",            { type = "bezier", points = { {0.0,  0.0},  {0.0,  1.0 } } })
hl.curve("menu_decel",               { type = "bezier", points = { {0.1,  1.0},  {0.0,  1.0 } } })
hl.curve("menu_accel",               { type = "bezier", points = { {0.52, 0.03}, {0.72, 0.08} } })
hl.curve("stall",                    { type = "bezier", points = { {1.0, -0.1},  {0.7,  0.85} } })

-- ===============================================================================================
-- Windows:
-- ===============================================================================================
--  "speed" means is the amount of ds (1ds = 100ms) the animation will take, lower - faster
--  "popin X%" means the element starts at X% size and scales up to 100%
--  "slide" = smooth translation; "slidevert" = vertical slide
-- ===============================================================================================

-- New window appears – scales from X% size to full size (pop‑in)
hl.animation({
    leaf = "windowsIn",
        enabled = true, speed = 5, bezier = "emphasizedDecel",
        style = "popin 1%"
})

-- New window fades in (opacity transition)
-- Long opacity transitions can cause color inconsistencies (noise), until size animation is done
-- I recommend setting the speed value lower than the animation speed,
-- so no opacity is moving after the size animation is done
hl.animation({
    leaf = "fadeIn",
        enabled = true, speed = 4, bezier = "emphasizedDecel" 
})

-- Closing window shrinks to X% size before vanishing (pop‑out)
hl.animation({
    leaf = "windowsOut",
        enabled = true, speed = 5, bezier = "emphasizedDecel",
        style = "popin 10%" 
})

-- Closing window fades out, leaving a smooth ghost (opacity animation)
hl.animation({
    leaf = "fadeOut",
        enabled = true, speed = 1, bezier = "emphasizedDecel"
    })

-- Window movement / resize – slides to its new position/size
hl.animation({
    leaf = "windowsMove",
        enabled = true, speed = 5, bezier = "emphasizedDecel",
        style = "slide"
})

-- Border colour transition speed when focus changes (opacity animation)
hl.animation({
    leaf = "border",
        enabled = true, speed = 5, bezier = "emphasizedDecel"
})

-- ===============================================================================================
-- Layers (overlays: launchers, notifications, logout dialogs):
-- ===============================================================================================

-- Layer appears – scales from X% size to full (e.g., Rofi opening)
hl.animation({
    leaf = "layersIn",
        enabled = true, speed = 1, bezier = "emphasizedDecel",
        style = "popin 93%" 
})

-- Layer disappears – shrinks to X% size before vanishing
hl.animation({
    leaf = "layersOut",
        enabled = true, speed = 1, bezier = "menu_accel",
        style = "popin 94%"
})

-- Layer fades in (opacity) when opening
hl.animation({
    leaf = "fadeLayersIn",
        enabled = true, speed = 1, bezier = "menu_decel"
})

-- Layer fades out (opacity) when closing
hl.animation({
    leaf = "fadeLayersOut",
        enabled = true, speed = 1, bezier = "stall"
})

-- ===============================================================================================
-- Workspaces
-- ===============================================================================================

-- Regular workspace switching – slides the new workspace into view
hl.animation({
    leaf = "workspaces",
        enabled = true, speed = 5, bezier = "menu_decel",
        style = "slide"
})

-- Special workspace (scratchpad) appears – slides vertically into view
hl.animation({
    leaf = "specialWorkspaceIn",
        enabled = true, speed = 1, bezier = "emphasizedDecel",
        style = "slidevert"
})

-- Special workspace disappears – slides vertically out of view
hl.animation({
    leaf = "specialWorkspaceOut",
        enabled = true, speed = 1, bezier = "emphasizedAccel",
        style = "slidevert"
})
