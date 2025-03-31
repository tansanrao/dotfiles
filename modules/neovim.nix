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
      cmp-path
      luasnip
      cmp_luasnip

      # TeX Support
      vimtex
      cmp-vimtex
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
    
      " When editing a file, always jump to the last known cursor position.
      " Don't do it when the position is invalid or when inside an event handler
      " (happens when dropping a file on gvim).
      autocmd BufReadPost *
      			\ if line("'\"") > 0 && line("'\"") <= line("$") |
      			\   exe "normal g`\"" |
      			\ endif

      " Vimtex configuration
      let g:vimtex_view_method = 'skim'
      let g:vimtex_view_skim_sync = 1
      let g:vimtex_view_skim_activate = 1
      let g:vimtex_quickfix_mode = 0
      let g:tex_flavor = 'latex'
      let g:vimtex_compiler_latexmk = {
          \ 'options' : [
          \   '-pdf',
          \   '-shell-escape',
          \   '-verbose',
          \   '-file-line-error',
          \   '-synctex=1',
          \   '-interaction=nonstopmode',
          \ ],
          \}

      " LSP Configuration
      lua << EOF
      -- LSP setup
      local lspconfig = require('lspconfig')

      -- clangd setup for C/C++
      lspconfig.clangd.setup {
        cmd = { "clangd", "--background-index"},
        filetypes = { "c", "cpp", "objc", "objcpp" },
      }
      
      -- texlab setup for LaTeX
      lspconfig.texlab.setup {
        capabilities = capabilities,
        settings = {
          texlab = {
            build = {
              onSave = true,
            },
            latexFormatter = "latexindent",
            forwardSearch = {
              executable = "displayline",
              args = {"%l", "%p", "%f"},
            }
          }
        }
      }
      
      -- LuaSnip setup
      local luasnip = require('luasnip')

      -- nvim-cmp setup
      local cmp = require('cmp')
      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-d>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-x><C-o>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'vimtex' },
        }, {
          { name = 'path' },
        }),
      })

      -- LSP keybindings
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
      vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, {})
      vim.keymap.set('n', 'gr', vim.lsp.buf.references, {})
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, {})
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, {})
      vim.keymap.set('n', '<leader>f', vim.lsp.buf.format, {})
      vim.keymap.set('n', '[g', vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })
      vim.keymap.set('n', ']g', vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })
     EOF
    '';
  };
}
