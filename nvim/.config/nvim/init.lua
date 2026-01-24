-- Plugin manager
require('config.lazy')
require('config.options')

pcall(dofile, vim.fn.stdpath("config") .. "/lua/current_theme.lua")
