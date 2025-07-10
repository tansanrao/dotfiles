-- ~/.config/nvim/init.lua
-- Main Neovim configuration entry point

-- Load core configuration
require('config.options')
require('config.keymaps')
require('config.autocmds')

-- Load plugin management and configurations
require('config.lazy') 