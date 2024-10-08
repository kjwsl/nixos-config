{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.larp.dev.neovim;
  plg = pkgs.vimPlugins;
in
{
  options.larp.dev.neovim = {
    enable = mkEnableOption "Neovim Dev";
    useVimPlugins = mkEnableOption "Neovim Plugins";
  };

  config = mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      plugins = mkIf cfg.useVimPlugins [
        plg.neogit
        plg.nvim-cmp
        plg.nvim-bqf
        plg.hop-nvim
        plg.airline
        plg.luasnip
        plg.fzf-lua


      ];
      viAlias = true;
      vimAlias = true;
      withNodeJs = true;
      withRuby = true;
      withPython3 = true;
      defaultEditor = true;
    };
    home.packages = with pkgs; [
      neovim-remote
    ];
  };
}
