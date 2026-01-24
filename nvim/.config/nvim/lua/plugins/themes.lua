return {
  -- List all themes you might ever use here.
  -- We set lazy=true so they don't load until we ask for them.
  -- The switcher script manually loads the active one via 'current_theme.lua'.

  { "catppuccin/nvim", name = "catppuccin", lazy = true },
  -- Noirbuddy (Requires colorbuddy dependency)
  { 
    "jesseleite/nvim-noirbuddy", 
    lazy = true, 
    name = "noirbuddy",
    dependencies = { "tjdevries/colorbuddy.nvim" } 
  },
  { 
    "metalelf0/black-metal-theme-neovim", 
    lazy = true, -- Lazy load allowed since your switcher invokes it manually
  },
}
