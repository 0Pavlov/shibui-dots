-- ~/.config/nvim/lua/plugins/catppuccin.lua
return {
  {
    "catppuccin/nvim",
    name = "catppuccin", -- This is an alias for lazy.nvim
    priority = 1000,
    lazy = false, -- Load on startup
    config = function()
      require("catppuccin").setup({
        flavour = "mocha", -- latte, frappe, macchiato, mocha
        -- You can add other Catppuccin specific configurations here if needed
        -- For example:
        -- transparent_background = true,
        -- term_colors = true,
        -- integrations = {
        --   cmp = true,
        --   gitsigns = true,
        --   nvimtree = true,
        --   telescope = true,
        --   -- For more, see Catppuccin's documentation
        -- }
      })
      -- After setting the flavour in setup, apply the base colorscheme name
      vim.cmd.colorscheme("catppuccin")
    end,
  },
}
