-- ~/.config/nvim/lua/config/autocmds.lua
-- Autocommands

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- General autocommands group
local general = augroup('General', { clear = true })

-- When editing a file, always jump to the last known cursor position
autocmd('BufReadPost', {
  group = general,
  pattern = '*',
  callback = function()
    local line = vim.fn.line("'\"")
    if line > 0 and line <= vim.fn.line('$') then
      vim.fn.setpos('.', vim.fn.getpos("'\""))
    end
  end,
  desc = 'Jump to last known cursor position'
})

-- Highlight on yank
autocmd('TextYankPost', {
  group = general,
  pattern = '*',
  callback = function()
    vim.highlight.on_yank({ higroup = 'Visual', timeout = 200 })
  end,
  desc = 'Highlight yanked text'
})

-- Kernel style indentation for C files
local c_indent = augroup('CIndent', { clear = true })
autocmd('FileType', {
  group = c_indent,
  pattern = 'c',
  callback = function()
    vim.opt_local.tabstop = 8
    vim.opt_local.softtabstop = 8
    vim.opt_local.shiftwidth = 8
    vim.opt_local.expandtab = false
  end,
  desc = 'Set kernel style indentation for C files'
})

-- Close some filetypes with <q>
autocmd('FileType', {
  group = general,
  pattern = { 'qf', 'help', 'man', 'lspinfo', 'spectre_panel' },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = event.buf, silent = true })
  end,
  desc = 'Close certain filetypes with q'
}) 