# Host: "wsl" — WSL NixOS machine (x86_64-linux).
{
  config,
  inputs,
  ...
}: {
  configurations.nixos.wsl.module = {pkgs, ...}: {
    imports = [
      inputs.nixos-wsl.nixosModules.default
      ../_nixos/options.nix
      ../_nixos/core/users.nix
      ../_nixos/core/fonts.nix
      ../_nixos/core/locale.nix
      ../_nixos/core/nix-ld.nix
      ../_nixos/development
      inputs.home-manager.nixosModules.home-manager
    ];

    wsl.enable = true;
    wsl.defaultUser = "ray";

    nixpkgs.hostPlatform = "x86_64-linux";

    networking.hostName = "wsl";
    nixpkgs.overlays = [
      inputs.neovim-nightly-overlay.overlays.default
      inputs.nur.overlays.default
    ];
    nixpkgs.config.allowUnfree = true;

    # Nix settings
    nix.extraOptions = "experimental-features = nix-command flakes";
    nix.settings = {
      auto-optimise-store = true;
      trusted-users = ["root" "@wheel" "@sudo" "ray"];
      extra-substituters = ["https://cache.numtide.com"];
      extra-trusted-public-keys = ["niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="];
    };
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    # Base packages
    environment.systemPackages = with pkgs; [
      vim
      wget
      zip
      unzip
      less
      wl-clipboard-rs
    ];

    # Home Manager
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.backupFileExtension = "bak";
    home-manager.extraSpecialArgs = {inherit inputs;};
    home-manager.users.ray = config.flake.modules.homeManager.base;

    system.stateVersion = "25.11";
  };
}
