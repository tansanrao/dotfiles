{ config, pkgs, ... }:

{
  # Configure tmux
  programs.tmux = {
    enable = true;
    shortcut = "Space"; 
    baseIndex = 1;
    escapeTime = 0;
    historyLimit = 10000;
    keyMode = "vi";
    terminal = "screen-256color";
    shell = "${pkgs.zsh}/bin/zsh";
    sensibleOnTop = false;

    # Add plugins from your old config
    plugins = [
      # {
      #   plugin = pkgs.tmuxPlugins.tpm;
      #   extraConfig = "";
      # }
      {
        plugin = pkgs.tmuxPlugins.catppuccin;
        extraConfig = ''
          # set catppuccin theme
          set -g @catppuccin_flavour 'mocha'
        '';
      }
    ];

    extraConfig = ''
      # Enable mouse mode
      set -g mouse on

      # Start panes at 1, not 0 (base-index is already set via baseIndex option)
      set -g pane-base-index 1
      set-window-option -g pane-base-index 1
      set-option -g renumber-windows on

      # Focus events enabled for terminals that support them
      set -g focus-events on
      
      # True color settings
      set -ag terminal-overrides ",$TERM:Tc"
      
      # Reload config
      bind R source-file ~/.config/tmux/tmux.conf \; display "Reloaded!"
    '';
  };
}
