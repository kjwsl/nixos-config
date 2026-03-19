# Base Home Manager identity: username, homeDirectory, stateVersion,
# shell aliases, and nixpkgs overlays/config.
# Contributes to flake.modules.homeManager.base (all platforms).
{
  config,
  inputs,
  lib,
  ...
}: {
  flake.modules.homeManager.base = {
    pkgs,
    lib,
    ...
  }: {
    imports = [
      inputs.catppuccin.homeModules.catppuccin
      inputs.nix-index-database.hmModules.nix-index
    ];

    home.username = lib.mkDefault config.username;
    home.homeDirectory = lib.mkDefault (
      if pkgs.stdenv.isDarwin
      then "/Users/${config.username}"
      else "/home/${config.username}"
    );

    home.shell.enableShellIntegration = true;
    home.shellAliases = {
      v = "nvim";
      "v." = "nvim .";
      g = "git";
    };

    home.sessionPath = [
        "$HOME/.local/bin"
        "$HOME/.cargo/bin"
    ];

    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      PAGER = "less";

      GITHUB_USERNAME = lib.mkDefault config.github_username;
      GITHUB_HTTPS = "https://github.com/${config.github_username}";
      GITHUB_SSH = "git@github.com:${config.github_username}";
    };

    services.ssh-agent.enable = true;
    services.gpg-agent.enable = true;
    services.tldr-update.enable = true;

    fonts.fontconfig.enable = true;

    home.stateVersion = "25.05";
  };
}
