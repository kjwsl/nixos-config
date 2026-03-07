# Shared NixOS configuration imported by every host.
# Contains: boot, networking, audio, printing, security, and nix daemon settings.
# Core sub-modules (users, fonts, locale) are imported here so all hosts get them.
{pkgs, ...}: {
  imports = [
    ../../modules/options.nix
    ../../modules/core/users.nix
    ../../modules/core/fonts.nix
    ../../modules/core/locale.nix
  ];

  # ── Bootloader ──────────────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;

  # ── Networking ───────────────────────────────────────────────────────────────
  networking.networkmanager.enable = true;

  # ── Audio (PipeWire) ─────────────────────────────────────────────────────────
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ── Printing ─────────────────────────────────────────────────────────────────
  services.printing.enable = true;

  # ── Base packages ────────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    vim
    wget
    zip
    unzip
    less
    coreutils
  ];

  # ── Nix daemon settings ──────────────────────────────────────────────────────
  nixpkgs.config.allowUnfree = true;

  nix.extraOptions = "experimental-features = nix-command flakes";
  nix.settings.auto-optimise-store = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
}
