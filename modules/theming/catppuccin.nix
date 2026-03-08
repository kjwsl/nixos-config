# Catppuccin theming for both Home Manager (all platforms) and NixOS desktop.
# Contributes to flake.modules.homeManager.base AND flake.modules.nixos.pc.
{inputs, ...}: {
  # HM catppuccin — applied everywhere
  flake.modules.homeManager.base = {...}: {
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
      nushell.enable = true;
      skim.enable = true;
      starship.enable = true;
      lazygit.enable = true;
      lsd.enable = true;
      television.enable = true;
      thunderbird.enable = true;
      yazi.enable = true;
      zed.enable = true;
      zellij.enable = true;
    };
  };

  # NixOS catppuccin — applied only on NixOS desktop
  flake.modules.nixos.pc = {
    imports = [inputs.catppuccin.nixosModules.catppuccin];

    catppuccin = {
      enable = true;
      flavor = "mocha";
      fcitx5 = {
        enable = true;
        enableRounded = true;
      };
    };
  };
}
