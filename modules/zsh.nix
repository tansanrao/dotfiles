{ config, pkgs, ...}:

{
  # Configure fzf for enhanced history search
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f --hidden --exclude .git";
    defaultOptions = ["--height 30%" "--layout=reverse" "--border"];
  };

  # Configure zsh with pure prompt
  programs.zsh = {
    enable = true;
    autosuggestion.enable = false;
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    plugins = [
      {
        name = "pure";
        src = pkgs.fetchFromGitHub {
          owner = "sindresorhus";
          repo = "pure";
          rev = "v1.23.0";
          sha256 = "sha256-BmQO4xqd/3QnpLUitD2obVxL0UulpboT8jGNEh4ri8k=";
        };
        file = "pure.zsh";
      }
    ];
    
    initExtra = ''
      # Pure prompt setup
      fpath+=("${pkgs.pure-prompt}/share/zsh/site-functions")
      autoload -U promptinit
      promptinit
      prompt pure

      # Aliases
      alias ls="ls --color=auto"
      alias ll="ls -la"
      alias vim="nvim"


      # History settings
      HISTSIZE=10000
      SAVEHIST=10000
      HISTFILE=~/.zsh_history
      setopt SHARE_HISTORY
      setopt HIST_IGNORE_DUPS

      bindkey -v
      bindkey '^R' history-incremental-search-backward

      # Helper functions
      # For when tmux attach causes problems with old agent in envvars
      function fixssh() {
        eval $(tmux show-env -s |grep '^SSH_')
      }

      # remove from known_hosts helper
      function rmkeys() {
        ssh-keygen -f "$HOME/.ssh/known_hosts" -R $1
      }

      # SSH through multiple jump hosts
      function jump() {
        # Check for minimum number of arguments (1 jump host + 1 final host)
        if (( ''$# < 2 )); then
          echo "Usage: jump host1 [host2 ... hostN]" >&2 
            return 1
            fi

            local -a hosts=("''$@")

            local last_host="''${hosts[-1]}"

            local -a proxies=("''${hosts[@]:0:''$#hosts-1}")

            local jump_string="''${(j:,:)proxies}"

            ssh -A -J "''${jump_string}" "''${last_host}"
      }
    '';
  };

  # Configure zoxide (smarter cd command)
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [
      "--cmd cd"
    ];
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}
