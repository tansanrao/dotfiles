{ pkgs, ... }:
{
  networking.hostName = "millennium-falcon";
  # Make sure the nix daemon always runs
  services.nix-daemon.enable = true;
  
  # if you use zsh (the default on new macOS installations),
  # you'll need to enable this so nix-darwin creates a zshrc sourcing needed environment changes
  programs.zsh.enable = true;
  # bash is enabled by default

    # System configuration
  system.defaults = {
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      NSAutomaticCapitalizationEnabled = false;  # disable auto capitalization
      NSAutomaticDashSubstitutionEnabled = false;  # disable auto dash substitution
      NSAutomaticPeriodSubstitutionEnabled = false;  # disable auto period substitution
      NSAutomaticQuoteSubstitutionEnabled = false;  # disable auto quote substitution
      NSAutomaticSpellingCorrectionEnabled = false;  # disable auto spelling correction
      NSNavPanelExpandedStateForSaveMode = true;  # expand save panel by default
      NSNavPanelExpandedStateForSaveMode2 = true;
    };
    dock = {
      autohide = true;
      mru-spaces = false;
    };
    finder = {
      _FXShowPosixPathInTitle = true;  # show full path in finder title
      AppleShowAllExtensions = true;  # show all file extensions
      FXEnableExtensionChangeWarning = false;  # disable warning when changing file extension
      QuitMenuItem = true;  # enable quit menu item
      ShowPathbar = true;  # show path bar
      ShowStatusBar = true;  # show status bar
    };
  };

  # Add ability to use Touch ID for sudo authentication
  security.pam.enableSudoTouchIdAuth = true;

  # Install and manage Homebrew packages if needed
  homebrew.enable = true;
  homebrew.onActivation = {
    autoUpdate = true; # Fetch the newest stable branch of Homebrew's git repo
    upgrade = true; # Upgrade outdated casks, formulae, and App Store apps
    # 'zap': uninstalls all formulae(and related files) not listed in the generated Brewfile
    cleanup = "zap";
  };
  homebrew.casks = [
    "alacritty"
    "firefox"
    "alfred"
    "discord"
    "tailscale"
    "zoom"
    "zotero"
    "vlc"
    "obsidian"
    "orbstack"
    "rectangle"
    "skim"
    "whatsapp"
    "slack"
    "windows-app"
    "microsoft-office"
    "font-ia-writer-duo"
    "font-ia-writer-mono"
    "font-ia-writer-quattro"
    "font-im-writing-nerd-font"
    "logitune"
    "logi-options+"
  ];
  homebrew.brews = [];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Used for backwards compatibility, please read the changelog before changing.
  system.stateVersion = 5;

  # Add your user to nixbld group
  users.users.tansanrao = {
    name = "tansanrao";
    home = "/Users/tansanrao";
    shell = "${pkgs.zsh}/bin/zsh";
  };

  # Home-Manager setup
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.tansanrao = { pkgs, ... }: {
    
    imports = [
      ../../modules/zsh.nix
      ../../modules/neovim.nix
      ../../modules/tmux.nix
      ../../modules/git.nix
    ];
    
    home.stateVersion = "24.11"; 
    
    home.packages = with pkgs; [
      # Basic Utilities
      ripgrep
      fd
      fzf
      bat
      htop
      # LSP dependencies
      clang-tools
    ];

  };
  

}
