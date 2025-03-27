{ config, pkgs, username ? "tansanrao", platform ? "linux", ... }:

{
  imports = [
    ./modules/zsh.nix
    ./modules/tmux.nix
    ./modules/neovim.nix
    ./modules/git.nix
  ];

  home.username = username;
  home.homeDirectory = if platform == "darwin" 
                       then "/Users/${username}"
                       else "/home/${username}";

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
    # Docker (handled differently on macOS, consider using Docker Desktop)
    ] ++ (if platform != "darwin" then [
      docker
      docker-compose
      docker-buildx
    ] else []) ++ [
    # LSP dependencies
    clang-tools
  ];
}
