{ config, pkgs, username, ... }:

{
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
    "rectangle"
    "skim"
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

  homebrew.masapps = {
    "1Password for Safari" = 1569813296;
    "Xcode" = 497799835;
    "Infuse" = 1136220934;
    "Fantastical" = 975937182;
    "Flow" = 1423210932;
    "Amphetamine" = 937984704;
  };

  # Create /etc/zshrc that loads the nix-darwin environment
  programs.zsh.enable = true;

  # Set your system hostname
  networking.hostName = "millennium-falcon";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Auto upgrade nix package and the daemon service
  services.nix-daemon.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  system.stateVersion = 5;

  # Add your user to nixbld group
  users.users.${username} = {
    name = "${username}";
    home = "/Users/${username}";
  };
}

