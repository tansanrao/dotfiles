-- ~/.config/nvim/lua/config/options.lua
-- Basic Neovim options

local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = false

-- Indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true

-- Search
opt.incsearch = true
opt.hlsearch = false
opt.showmatch = true
opt.ignorecase = true
opt.smartcase = true

-- General
opt.hidden = true
opt.mouse = 'a'
opt.background = 'dark'
opt.termguicolors = true

-- Backup and swap
opt.backup = false
opt.writebackup = false
opt.swapfile = false

-- Completion
opt.completeopt = { 'menu', 'menuone', 'noselect' }

-- Split windows
opt.splitright = true
opt.splitbelow = true

-- Scrolling
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Clipboard
opt.clipboard = 'unnamedplus' 