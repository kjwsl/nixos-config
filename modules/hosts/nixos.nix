# Host: "nixos" — desktop NixOS machine (x86_64-linux, Intel).
# Registers a deferredModule under configurations.nixos.nixos.
# Audio and catppuccin are provided via flake.modules.nixos.pc.
# Home Manager config is provided via flake.modules.homeManager.base.
{
  config,
  inputs,
  ...
}: {
  configurations.nixos.nixos.module = {
    pkgs,
    lib,
    ...
  }: let
    defaultShell = pkgs.fish;
  in {
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

    # Torrent
    services.qbittorrent = {
        enable = true;
        user = config.username;
    };

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
      ]
      ++ [
        inputs.zen-browser.packages.x86_64-linux.twilight
      ];


    # Nix settings
    nix.extraOptions = "experimental-features = nix-command flakes";
    nix.settings = {
      auto-optimise-store = true;
      extra-substituters = ["https://cache.numtide.com"];
      extra-trusted-public-keys = ["niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="];
    };
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    programs = {
      bash.interactiveShellInit =
        # zsh
        ''
          if ! [ "$TERM" = "dumb" ] && [ -z "$BASH_EXECUTION_STRING" ]; then
              exec "${lib.getExe defaultShell}"
                  fi
        '';

      zsh.interactiveShellInit =
        # zsh
        ''
          if ! [ "$TERM" = "dumb" ] && [ -z "$ZSH_EXECUTION_STRING" ]; then
              exec "${lib.getExe defaultShell}"
                  fi
        '';
      fish.enable = true;
    };

    # Gaming stack
    my.stacks.gaming.enable = true;

    # Home Manager
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.backupFileExtension = "bak";
    home-manager.extraSpecialArgs = {inherit inputs;};
    home-manager.users.ray = config.flake.modules.homeManager.base;

    system.stateVersion = "25.11";
  };
}
