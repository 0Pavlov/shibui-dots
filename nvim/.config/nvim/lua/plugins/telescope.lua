return {
  'nvim-telescope/telescope.nvim',
  tag = '0.1.8', -- Or your preferred tag/branch, e.g., branch = '0.1.x'
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local builtin = require('telescope.builtin')
    local home_dir = vim.fn.expand('~')

    -- Keymap to search files in the home directory when pressing "ff" in normal mode
    vim.keymap.set('n', 'ff', function()
      builtin.find_files({
        prompt_title = "Find Files in Home (~)",
        cwd = home_dir,
        -- If you want to include hidden files and ignore .gitignore for this search:
        find_command = { 'rg', '--files', '--hidden', '--no-ignore', '--glob', '!.git' }
      })
    end, { desc = 'Telescope Find Files in Home (~)' })
  end
}
