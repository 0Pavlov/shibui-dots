require("noirbuddy").setup({
    colors = {
        primary = "#dedede",   -- Your textPrimary
        secondary = "#808080", -- Your textSecondary
        background = "#121212", -- Your background
    },
    preset = "minimal",
})
vim.cmd.colorscheme("noirbuddy")

-- Override the String color *after* the theme has loaded
-- This ensures your settings win against the preset.
local Color = require("colorbuddy.color").Color
local Group = require("colorbuddy.group").Group
local c = require("colorbuddy.color").colors
local s = require("colorbuddy.style").styles

-- Define your custom orange
Color.new("MyOrange", "#ff9e64")

-- Apply it to String and @string (TreeSitter)
Group.new("String", c.MyOrange, nil, s.none)
Group.new("@string", c.MyOrange, nil, s.none)

-- Apply to PreProc for python includes
Group.new("PreProc", c.MyOrange, nil, s.none)
