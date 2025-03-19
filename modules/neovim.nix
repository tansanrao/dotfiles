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
    ];

    extraConfig = ''
      " Basic settings
      set number
      set expandtab
      set tabstop=2
      set shiftwidth=2
      set smartindent
      set hidden
      set incsearch
      set ignorecase
      set smartcase

      " Appearance
      colorscheme catppuccin-mocha
      let g:airline_theme = 'catppuccin'

      set background=dark

      " Key mappings
      let mapleader = " "

      " Split navigation
      nnoremap <C-h> <C-w>h
      nnoremap <C-j> <C-w>j
      nnoremap <C-k> <C-w>k
      nnoremap <C-l> <C-w>l

      " FZF mappings
      nnoremap <leader>ff <cmd>Files<CR>
      nnoremap <leader>fg <cmd>Rg<CR>
      nnoremap <leader>fb <cmd>Buffers<CR>
    '';
  };
}
