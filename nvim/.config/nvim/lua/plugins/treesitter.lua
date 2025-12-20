return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "c",
        "glsl",
        "lua",
        "vim",
        "vimdoc",
        "javascript",
        "html",
        "python",
        "css",
        "sql",
        "query",
      },
      sync_install = false,
      highlight = {
        enable = true,
      },
      indent = {
        enable = true,
      },
    })
  end,
}
