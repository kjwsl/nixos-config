{ config, pkgs, ... }:

{
  # Neovim - Just install the package, use existing ~/.config/nvim/ config
  home.packages = with pkgs; [
    neovim
  ];
  
  # Set as default editor
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
