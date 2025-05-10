{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ray.home.modules.dev.neovim;
  plg = pkgs.vimPlugins;
in
{
  options.ray.home.modules.dev.neovim = {
    enable = mkEnableOption "Neovim Dev" // { default = false; };
    useVimPlugins = mkEnableOption "Neovim Plugins";
  };

  config = mkMerge [
    (mkIf false {}) # Always disabled, no config
    (mkIf cfg.enable {
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
    })
  ];
}
