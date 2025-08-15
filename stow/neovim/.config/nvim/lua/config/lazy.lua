-- ~/.config/nvim/lua/config/lazy.lua
-- Lazy.nvim plugin manager setup

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require("lazy").setup({
  -- Essential plugins
  { 'tpope/vim-sensible' },
  { 'tpope/vim-surround' },
  { 'tpope/vim-commentary' },
  { 'tpope/vim-fugitive' },

  -- Appearance
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        integrations = {
          nvimtree = true,
          telescope = true,
          which_key = true,
        },
      })
      vim.cmd.colorscheme "catppuccin"
    end,
  },
  
  {
    'vim-airline/vim-airline',
    dependencies = { 'vim-airline/vim-airline-themes' },
    config = function()
      vim.g.airline_theme = 'catppuccin'
      vim.g['airline#extensions#tabline#enabled'] = 1
      vim.g['airline#extensions#whitespace#mixed_indent_algo'] = 1
    end,
  },

  -- Navigation and search
  {
    'junegunn/fzf.vim',
    dependencies = { 'junegunn/fzf' },
  },
  
  {
    'preservim/nerdtree',
    config = function()
      vim.g.NERDTreeShowHidden = 1
      vim.g.NERDTreeMinimalUI = 1
      vim.g.NERDTreeDirArrows = 1
      vim.g.NERDTreeAutoDeleteBuffer = 1
    end,
  },

  -- LSP Support
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'hrsh7th/nvim-cmp',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
    },
    config = function()
      require('plugins.lsp')
    end,
  },

  -- TeX Support
  {
    'lervag/vimtex',
    ft = 'tex',
    config = function()
      vim.g.vimtex_view_method = 'skim'
      vim.g.vimtex_view_skim_sync = 1
      vim.g.vimtex_view_skim_activate = 1
      vim.g.vimtex_quickfix_mode = 0
      vim.g.tex_flavor = 'latex'
      vim.g.vimtex_compiler_latexmk = {
        options = {
          '-pdf',
          '-shell-escape',
          '-verbose',
          '-file-line-error',
          '-synctex=1',
          '-interaction=nonstopmode',
        },
      }
    end,
  },
  
  {
    'micangl/cmp-vimtex',
    ft = 'tex',
  },

}, {
  -- Lazy.nvim options
  ui = {
    border = "rounded",
  },
  performance = {
    cache = {
      enabled = true,
    },
    reset_packpath = true,
    rtp = {
      reset = true,
      paths = {},
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
}) 