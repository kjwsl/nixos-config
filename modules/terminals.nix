{ config, pkgs, lib, ... }:

{
  programs.alacritty = {
    enable = true;
    settings = {
      import = [
        "~/.config/alacritty/themes/themes/catppucin_frappe.toml"
      ];
      shell = {
        program = "/bin/zsh";
        args = ["-l"];
      };
      font = {
        size = 13;
        normal = {
          family = "CaskaydiaCove Nerd Font Mono";
        };
      };
      window = {
        opacity = 0.9;
        blur = true;
      };
    };
  };

  programs.kitty = {
    enable = true;
    settings = {
      enable_audio_bell = false;
      font_family = "Cartograph CF Italic";
      font_size = 13;
      disable_ligatures = "never";
      url_color = "#fff";
      url_style = "curly";
      
      # Include color config (will be managed as separate file)
      include = "color.ini";
    };
  };
  
  # Terminal configurations that don't have good HM modules yet
  home.file = {
    # Kitty color configuration (referenced by kitty.conf)
    ".config/kitty/color.ini".source = ../dotfiles/kitty/color.ini;
    
    # Alacritty themes directory (if it exists in chezmoi)
    ".config/alacritty/themes".source = ../dotfiles/alacritty/themes;
    
    # Ghostty - no good HM module yet
    ".config/ghostty".source = ../dotfiles/ghostty;
    
    # WezTerm - no good HM module yet  
    ".config/wezterm".source = ../dotfiles/wezterm;
  };
}