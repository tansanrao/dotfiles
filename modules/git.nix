{ config, pkgs, ... }:

{
  # Configure git
  programs.git = {
    enable = true;
    userName = "Tanuj Ravi Rao";
    userEmail = "email@tansanrao.com";

    aliases = {
      co = "checkout";
      ci = "commit";
      st = "status";
      br = "branch";
      hist = "log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short";
    };

    extraConfig = {
      core.editor = "nvim";
      init.defaultBranch = "main";
    };
  };
}
