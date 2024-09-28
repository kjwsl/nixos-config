{ config, lib, pkgs, system, home, ... }:
with lib;
let
  cfg = config.larp.opts.dotfiles;
  dotfiles = builtins.fetchGit {
    url = "${cfg.gitUrl}";
    ref = "master";
    submodules = true;
    allRefs = true;
  };

  dotfilesList = [
    ".bashrc"
    ".zshrc"
    ".gitconfig"
    ".config/nvim"
    ".config/gh"
    ".config/wezterm"
  ];
  sourcePath = "${config.home.homeDirectory}/github/.dotfiles";

  mkDotfile = file: {
    source = "${dotfiles}/${file}";
  };

  dotfilesAttrs = builtins.listToAttrs (map (file: { name = file; value = mkDotfile file; }) dotfilesList);

in
{
  options.larp.opts.dotfiles =
    {
      enable = mkEnableOption "dotfiles";
      gitUrl = mkOption {
        type = types.str;
        default = "https://github.com/kjwsl/.dotfiles";
      };
      path = mkOption
        {
          type = types.path;
          default = sourcePath;
        };
    };

  config = mkIf cfg.enable
    {
      home.packages = [ pkgs.git ];
      home.file = dotfilesAttrs;
    };
}


