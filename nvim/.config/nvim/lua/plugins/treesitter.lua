return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    -- Check if the plugin is available before trying to configure it
    local status_ok, configs = pcall(require, "nvim-treesitter.configs")
    if not status_ok then
      return
    end

    configs.setup({
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
