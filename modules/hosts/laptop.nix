# Host: "laptop" — modular NixOS desktop machine (x86_64-linux, placeholder hardware).
# Registers a deferredModule under configurations.nixos.laptop.
# Audio and catppuccin are provided via flake.modules.nixos.pc.
# Home Manager config is provided via flake.modules.homeManager.base.
{
  config,
  inputs,
  ...
}: {
  configurations.nixos.laptop.module = {pkgs, ...}: {
    imports = [
      ../_hardware/laptop.nix
      ../_nixos/options.nix
      ../_nixos/core/users.nix
      ../_nixos/core/fonts.nix
      ../_nixos/core/locale.nix
      ../_nixos/desktop
      ../_nixos/development
      ../_nixos/stacks/ai.nix
      ../_nixos/stacks/music.nix
      ../_nixos/stacks/gaming.nix
      ../_nixos/profiles/work.nix
      inputs.home-manager.nixosModules.home-manager
      config.flake.modules.nixos.pc
    ];

    networking.hostName = "laptop";
    nixpkgs.overlays = [
      inputs.neovim-nightly-overlay.overlays.default
      inputs.nur.overlays.default
    ];
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
    environment.systemPackages = with pkgs;
      [
        vim
        wget
        zip
        unzip
        less
        wezterm
        wl-clipboard-rs
        nodejs
      ]
      ++ [
        inputs.zen-browser.packages.x86_64-linux.twilight
      ];

    # Docker
    virtualisation.docker = {
      enable = true;
      enableOnBoot = true;
      storageDriver = "overlay2";
    };

    # Profile & stacks
    my.profile = "desktop";
    my.stacks.gaming.enable = true;

    # Nix settings
    nix.extraOptions = "experimental-features = nix-command flakes";
    nix.settings.auto-optimise-store = true;
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    # Home Manager
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.backupFileExtension = "bak";
    home-manager.extraSpecialArgs = {inherit inputs;};
    home-manager.users.ray = config.flake.modules.homeManager.base;

    system.stateVersion = "25.11";
  };
}
