{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;

    plugins = with pkgs.vimPlugins; [
      # Basics
      vim-sensible
      vim-surround
      vim-commentary
      vim-fugitive

      # Appearance
      catppuccin-nvim
      vim-airline

      # Navigation and search
      fzf-vim

      # LSP Support
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
    ];

    extraConfig = ''
      " Basic settings
      set number
      set smartindent
      set hidden
      set incsearch
      set nohlsearch
      set showmatch
      set ignorecase
      set smartcase

      " Appearance
      colorscheme catppuccin-mocha
      let g:airline_theme = 'catppuccin'
      set background=dark

      " Airline config
      let g:airline#extensions#tabline#enabled = 1
      let g:airline#extensions#whitespace#mixed_indent_algo = 1

      " Key mappings
      let mapleader = " "
      nnoremap <F2> :set number!<CR>
      set pastetoggle=<F3>

      " Split navigation
      nnoremap <C-h> <C-w>h
      nnoremap <C-j> <C-w>j
      nnoremap <C-k> <C-w>k
      nnoremap <C-l> <C-w>l

      " FZF mappings
      nnoremap <leader>ff <cmd>Files<CR>
      nnoremap <leader>fg <cmd>Rg<CR>
      nnoremap <leader>fb <cmd>Buffers<CR>
      
      " Indentation
      set tabstop=2
      set shiftwidth=2
      set expandtab

      " Kernel style indentation
      augroup c_indent
        au!
        autocmd FileType c setlocal tabstop=8 softtabstop=8 shiftwidth=8 noexpandtab
      augroup END

      " LSP Configuration
      lua << EOF
      -- LSP setup
      local lspconfig = require('lspconfig')

      -- clangd setup for C/C++
      lspconfig.clangd.setup {
        cmd = { "clangd", "--background-index"},
        filetypes = { "c", "cpp", "objc", "objcpp" },
      }

      -- nvim-cmp setup
      local cmp = require('cmp')
      cmp.setup({
        completion = {
          autocomplete = false,  -- Disable automatic completion
        },
        mapping = {
          ['<Tab>'] = cmp.mapping.select_next_item(),
          ['<S-Tab>'] = cmp.mapping.select_prev_item(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
        },
        sources = {
          { name = 'nvim_lsp' },
        },
      })

      -- LSP keybindings
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
      vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, {})
      vim.keymap.set('n', 'gr', vim.lsp.buf.references, {})
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, {})
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, {})
      vim.keymap.set('n', '<leader>f', vim.lsp.buf.format, {})
     EOF
    '';
  };
}
