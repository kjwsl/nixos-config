# Laptop host configuration.
# Imports: common baseline + hardware + all feature modules.
# Sets my.profile and enables default stacks for a personal desktop machine.
{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../common

    # Feature modules
    ../../modules/desktop
    ../../modules/development

    # Toggleable stacks (options defined in modules/options.nix via common)
    ../../modules/stacks/ai.nix
    ../../modules/stacks/music.nix
    ../../modules/stacks/gaming.nix

    # Profile-based overrides
    ../../modules/profiles/work.nix
  ];

  # ── Identity ──────────────────────────────────────────────────────────────────
  networking.hostName = "laptop";

  # ── Profile & stacks ─────────────────────────────────────────────────────────
  my.profile = "desktop";
  my.stacks.gaming.enable = true;

  # ── Catppuccin theming ────────────────────────────────────────────────────────
  catppuccin = {
    enable = true;
    flavor = "mocha";
    fcitx5 = {
      enable = true;
      enableRounded = true;
    };
  };

  # ── Additional laptop packages ────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    wezterm
    wl-clipboard-rs
    nodejs
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.twilight
  ];

  # ── Container / virtualisation ────────────────────────────────────────────────
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    storageDriver = "overlay2";
  };

  system.stateVersion = "25.11";
}
