-- ~/.config/nvim/lua/config/keymaps.lua
-- Key mappings

local keymap = vim.keymap.set

-- Set leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- General keymaps
keymap('n', '<F2>', ':set number!<CR>', { desc = 'Toggle line numbers' })

-- Split navigation
keymap('n', '<C-h>', '<C-w>h', { desc = 'Go to left window' })
keymap('n', '<C-j>', '<C-w>j', { desc = 'Go to bottom window' })
keymap('n', '<C-k>', '<C-w>k', { desc = 'Go to top window' })
keymap('n', '<C-l>', '<C-w>l', { desc = 'Go to right window' })

-- Better indenting
keymap('v', '<', '<gv', { desc = 'Indent left' })
keymap('v', '>', '>gv', { desc = 'Indent right' })

-- Move lines up/down
keymap('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move line down' })
keymap('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move line up' })

-- Clear search highlighting
keymap('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })

-- Better paste
keymap('v', 'p', '"_dP', { desc = 'Paste without yanking' })

-- LSP keymaps (will be overridden by LSP setup if available)
keymap('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definition' })
keymap('n', 'gi', vim.lsp.buf.implementation, { desc = 'Go to implementation' })
keymap('n', 'gr', vim.lsp.buf.references, { desc = 'Show references' })
keymap('n', 'K', vim.lsp.buf.hover, { desc = 'Show hover information' })
keymap('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'Rename symbol' })
keymap('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code actions' })
keymap('n', '<leader>f', vim.lsp.buf.format, { desc = 'Format code' })
keymap('n', '[g', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic' })
keymap('n', ']g', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic' })

-- Plugin-specific keymaps (these will be used by plugins when available)
-- FZF/Telescope
keymap('n', '<leader>ff', '<cmd>Files<CR>', { desc = 'Find files' })
keymap('n', '<leader>fg', '<cmd>Rg<CR>', { desc = 'Live grep' })
keymap('n', '<leader>fb', '<cmd>Buffers<CR>', { desc = 'Find buffers' })

-- NERDTree/File explorer
keymap('n', '<leader>n', '<cmd>NERDTreeToggle<CR>', { desc = 'Toggle file tree' })
keymap('n', '<leader>nf', '<cmd>NERDTreeFind<CR>', { desc = 'Find current file in tree' }) 