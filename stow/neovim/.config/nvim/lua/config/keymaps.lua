-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Toggle Rosé Pine (dark) <-> Rosé Pine Dawn (light) based on &background
local function apply_rp(bg)
  vim.o.background = bg
  vim.cmd.colorscheme("rose-pine") -- variant picked from background
  vim.notify("Neovim theme: Rosé Pine " .. (bg == "light" and "Dawn (light)" or "Main (dark)"))
end

local function toggle_rose_pine()
  local next_bg = (vim.o.background == "light") and "dark" or "light"
  apply_rp(next_bg)
end

vim.keymap.set("n", "<leader>ut", toggle_rose_pine, { desc = "Toggle Rosé Pine/Dawn" })
