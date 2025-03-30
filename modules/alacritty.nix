{ config, pkgs, ... }:

{
  # Configure alacritty
  programs.alacritty = {
    enable = true;
    package = pkgs.emptyDirectory;
    settings = {
      cursor = {
        style = "Block";
      };

      window = {
        opacity = 1.0;
      };

      font = {
        normal = {
          family = "iMWritingMono Nerd Font";
          style = "Regular";
        };
        size = 14;
      };
      colors = {
        primary = {
          background = "0x1e1e2e";
          foreground = "0xcdd6f4";
          dim_foreground = "0x7f849c";
          bright_foreground = "0xcdd6f4";
        };
      
        cursor = {
          text = "0x1e1e2e";
          cursor = "0xf5e0dc";
        };
      
        vi_mode_cursor = {
          text = "0x1e1e2e";
          cursor = "0xb4befe";
        };
      
        search = {
          matches = {
            foreground = "0x1e1e2e";
            background = "0xa6adc8";
          };
          focused_match = {
            foreground = "0x1e1e2e";
            background = "0xa6e3a1";
          };
        };
      
        footer_bar = {
          foreground = "0x1e1e2e";
          background = "0xa6adc8";
        };
      
        hints = {
          start = {
            foreground = "0x1e1e2e";
            background = "0xf9e2af";
          };
          end = {
            foreground = "0x1e1e2e";
            background = "0xa6adc8";
          };
        };
      
        selection = {
          text = "0x1e1e2e";
          background = "0xf5e0dc";
        };
      
        normal = {
          black = "0x45475a";
          red = "0xf38ba8";
          green = "0xa6e3a1";
          yellow = "0xf9e2af";
          blue = "0x89b4fa";
          magenta = "0xf5c2e7";
          cyan = "0x94e2d5";
          white = "0xbac2de";
        };
      
        bright = {
          black = "0x585b70";
          red = "0xf38ba8";
          green = "0xa6e3a1";
          yellow = "0xf9e2af";
          blue = "0x89b4fa";
          magenta = "0xf5c2e7";
          cyan = "0x94e2d5";
          white = "0xa6adc8";
        };
      
        indexed_colors = [
          {
            index = 16;
            color = "0xfab387";
          }
          {
            index = 17;
            color = "0xf5e0dc";
          }
        ];
      };
    };
  };
}
