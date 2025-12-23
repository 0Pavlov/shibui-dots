return {
  {
    "echasnovski/mini.hipatterns",
    event = "BufReadPre",
    opts = function()
      local hipatterns = require("mini.hipatterns")
      return {
        highlighters = {
          -- 1. Standard Hex colors (e.g., #ff0000)
          hex_color = hipatterns.gen_highlighter.hex_color(),

          -- 2. Custom Hyprland rgba(AARRGGBB) or rgba(RRGGBBAA) format
          hyprland_color = {
            -- Match "rgba(" followed by hex digits, followed by ")"
            pattern = 'rgba%([%x]+%)', 
            group = function(_, match)
              -- Extract the hex part inside the parentheses
              local hex = match:match('rgba%((%x+)%)')
              if hex then
                -- Hyprland often uses 8 digits (RRGGBBAA). 
                -- We take the first 6 characters for the visual color.
                -- (If your config uses AARRGGBB, change sub(1,6) to sub(3,8))
                local color = '#' .. hex:sub(1, 6)
                
                -- Generate the highlight group with a background color
                return hipatterns.compute_hex_color_group(color, 'bg')
              end
            end,
          },
        },
      }
    end,
  },
}
