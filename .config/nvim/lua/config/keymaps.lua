-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

Snacks.toggle({
  name = "Completion (Buffer)",
  get = function()
    return vim.b.completion ~= false
  end,
  set = function(enabled)
    vim.b.completion = enabled
  end,
}):map("<leader>bc")
