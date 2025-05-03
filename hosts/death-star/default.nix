{ config, pkgs, ... }:

{
  imports = [
    ../../modules/zsh.nix
    ../../modules/tmux.nix
    ../../modules/neovim.nix
    ../../modules/git.nix
  ];

  home.username = "tansanrao";
  home.homeDirectory = "/home/tansanrao";

  home.stateVersion = "24.11"; 

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    # Basic Utilities
    ripgrep
    fd
    fzf
    bat
    htop
    # Docker
    docker
    docker-compose
    docker-buildx
    # LSP depedencies
    clang-tools
  ];
}
