# Host: "nixos" — desktop NixOS machine (x86_64-linux, Intel).
# Registers a deferredModule under configurations.nixos.nixos.
# Audio and catppuccin are provided via flake.modules.nixos.pc.
# Home Manager config is provided via flake.modules.homeManager.base.
{
  config,
  inputs,
  ...
}: {
  configurations.nixos.nixos.module = {pkgs, ...}: {
    imports = [
      ../_hardware/nixos.nix
      ../_nixos/options.nix
      ../_nixos/core/users.nix
      ../_nixos/core/fonts.nix
      ../_nixos/core/locale.nix
      ../_nixos/desktop
      ../_nixos/development
      ../_nixos/stacks/gaming.nix
      inputs.home-manager.nixosModules.home-manager
      config.flake.modules.nixos.pc
    ];

    networking.hostName = "nixos";
    nixpkgs.overlays = [inputs.neovim-nightly-overlay.overlays.default];
    nixpkgs.config.allowUnfree = true;

    # Bootloader
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.systemd-boot.configurationLimit = 10;

    # Networking
    networking.networkmanager.enable = true;

    # Printing
    services.printing.enable = true;

    # Base packages
    environment.systemPackages = with pkgs; [
      vim
      wget
      zip
      unzip
      less
      wezterm
      wl-clipboard-rs
    ] ++ [
      inputs.zen-browser.packages.x86_64-linux.twilight
    ];

    # Docker
    virtualisation.docker = {
      enable = true;
      enableOnBoot = true;
      storageDriver = "overlay2";
    };

    # Nix settings
    nix.extraOptions = "experimental-features = nix-command flakes";
    nix.settings.auto-optimise-store = true;
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    # Gaming stack
    my.stacks.gaming.enable = true;

    # Home Manager
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.backupFileExtension = "bak";
    home-manager.users.ray = config.flake.modules.homeManager.base;

    system.stateVersion = "25.11";
  };
}
