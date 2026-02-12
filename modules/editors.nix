{ config, pkgs, lib, ... }:

{
  programs.helix = {
    enable = true;
    
    settings = {
      theme = "catppuccin_mocha";
      
      editor = {
        line-number = "relative";
        auto-format = false;
        auto-pairs = false;
      };
      
      keys = {
        normal = {
          K = "hover";
          space = {
            "=" = ":format";
            f = {
              f = "file_picker";
              F = "file_picker_in_current_directory";
              s = "symbol_picker";
              S = "workspace_symbol_picker";
              "." = "last_picker";
            };
            s = {
              h = "vsplit";
              l = "vsplit";
              j = "hsplit";
              k = "hsplit";
            };
            w = {
              d = "wclose";
              w = ":w";
              q = ":wq";
              Q = ":wqa";
            };
            q = {
              q = ":q";
            };
          };
        };
        insert = {
          z = {
            x = "normal_mode";
          };
        };
      };
    };
  };
  
  # Note: Neovim config is managed by chezmoi external git repo
  # Don't try to nixify it - let chezmoi handle the external repo
}