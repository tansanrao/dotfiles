local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local function notify(msg, level)
  vim.schedule(function()
    vim.notify(msg, level or vim.log.levels.WARN, { title = "dotfiles" })
  end)
end

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  if vim.fn.executable("git") == 0 then
    notify("lazy.nvim is missing and git is unavailable; starting without plugin manager.", vim.log.levels.WARN)
    return
  end

  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    notify("Failed to clone lazy.nvim; starting without plugins.\n" .. out, vim.log.levels.ERROR)
    return
  end
end
vim.opt.rtp:prepend(lazypath)

local ok, lazy = pcall(require, "lazy")
if not ok then
  notify("lazy.nvim failed to load; starting without plugins.", vim.log.levels.ERROR)
  return
end

lazy.setup({
  spec = {
    -- add LazyVim and import its plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- import/override with your plugins
    { import = "plugins" },
  },
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = {
    enabled = true, -- check for plugin updates periodically
    notify = false, -- notify on update
  }, -- automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
