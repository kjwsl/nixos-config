# Home Manager configuration for the "aileron" user.
# Imports common shell/tool config and applies Catppuccin theming.
{
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../common
    inputs.catppuccin.homeModules.catppuccin
  ];

  nixpkgs.overlays = [
    inputs.neovim-nightly-overlay.overlays.default
  ];

  home.username = "aileron";
  home.homeDirectory = lib.mkDefault "/home/aileron";

  # ── Catppuccin theming ────────────────────────────────────────────────────────
  catppuccin = {
    enable = true;
    flavor = "mocha";

    anki.enable = true;
    atuin.enable = true;
    bat.enable = true;
    bottom.enable = true;
    broot.enable = true;
    btop.enable = true;
    delta.enable = true;
    eza.enable = true;
    fish.enable = true;
    fzf.enable = true;
    gemini-cli.enable = true;
    ghostty.enable = true;
    helix.enable = true;
    lazygit.enable = true;
    lsd.enable = true;
    nushell.enable = true;
    skim.enable = true;
    starship.enable = true;
    television.enable = true;
    thunderbird.enable = true;
    yazi.enable = true;
    zed.enable = true;
    zellij.enable = true;
  };

  home.stateVersion = "25.11";
}
