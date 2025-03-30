{ config, pkgs, lib, ... }:
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
    LaunchServices = {
      LSQuarantine = false;
    };
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
      show-recents = false;
      launchanim = true;
      mouse-over-hilite-stack = true;
      orientation = "bottom";
      tilesize = 48;
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

  # Block ability to use Touch ID for sudo authentication
  security.pam.enableSudoTouchIdAuth = false;

  # Install and manage Homebrew packages if needed
  homebrew.enable = true;
  homebrew.onActivation = {
    autoUpdate = true; # Fetch the newest stable branch of Homebrew's git repo
    upgrade = true; # Upgrade outdated casks, formulae, and App Store apps
    # 'zap': uninstalls all formulae(and related files) not listed in the generated Brewfile
    cleanup = "zap";
  };
  homebrew.casks = [
    "firefox"
    "alacritty"
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
    "slack"
    "windows-app"
    "microsoft-office"
    "font-ia-writer-duo"
    "font-ia-writer-mono"
    "font-ia-writer-quattro"
    "font-im-writing-nerd-font"
    "logi-options+"
    "1password"
  ];
  homebrew.brews = [];

  homebrew.masApps = {
    "Xcode" = 497799835;
    "Infuse" = 1136220934;
    "Fantastical" = 975937182;
    "Flow" = 1423210932;
    "Amphetamine" = 937984704;
  };

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
      ../../modules/alacritty.nix
    ];
    
    home.stateVersion = "24.11"; 
    
    home.packages = with pkgs; [
      # Basic Utilities
      ripgrep
      fd
      fzf
      bat
      htop

      # Dock automation
      dockutil

      # LSP dependencies
      clang-tools
    ];

  };

  imports = [
    ../../darwin/dock.nix
  ];

  # Fully declarative dock using the latest from Nix Store
  local = {
    dock.enable = true;
    dock.entries = [
      { path = "/Applications/Slack.app/"; }
      { path = "/System/Applications/Messages.app/"; }
      { path = "/System/Applications/Facetime.app/"; }
      { path = "/Applications/Alacritty.app/"; }
      { path = "/System/Applications/Music.app/"; }
      { path = "/System/Applications/Home.app/"; }
      { path = "/System/Applications/Mail.app/"; }
      { path = "/Applications/Firefox.app/"; }
      {
        path = "${config.users.users.tansanrao.home}/Downloads";
        section = "others";
        options = "--sort name --view grid --display stack";
      }
    ];
  };

}
