-- Line numbers
vim.opt.nu = true
vim.opt.rnu = true

-- Disable wrapping
vim.opt.wrap = false

-- Consistent indentation
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- For the backspace to work correctly
vim.opt.backspace = 'indent,eol,start'

-- Turn on the syntax highlighting
vim.cmd('syntax on')

-- Prevent vim from creating an undo files
-- vim.opt.noundofile = true

-- Filetype specific highlighting and indentation
vim.cmd('filetype plugin indent on')

-- Associate additional file extensions with the GLSL filetype
vim.filetype.add({
  extension = {
    vert = "glsl",
    frag = "glsl",
    geom = "glsl",
    comp = "glsl",
  },
})
