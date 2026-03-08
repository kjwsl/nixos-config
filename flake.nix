{
  description = "NixOS + Home Manager flake-parts configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";

    flake-parts.url = "github:hercules-ci/flake-parts";

    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin.url = "github:catppuccin/nix";

    wrappers.url = "github:BirdeeHub/nix-wrapper-modules";

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      # ── Per-system outputs (devShells, packages, checks, etc.) ─────────────────
      systems = ["aarch64-darwin" "x86_64-linux" "aarch64-linux"];

      # ── System-independent (flake-level) outputs ───────────────────────────────
      flake = {
        # ── Home Manager modules ──────────────────────────────────────────────────
        homeModules = {
          ray = {
            pkgs,
            lib,
            ...
          }: {
            imports = [
              {nixpkgs.overlays = [inputs.neovim-nightly-overlay.overlays.default];}
              ./home/home.nix
              inputs.catppuccin.homeModules.catppuccin
            ];
            home.username = "ray";
            home.homeDirectory = lib.mkDefault (
              if pkgs.stdenv.isDarwin
              then "/Users/ray"
              else "/home/ray"
            );
          };
        };

        # ── NixOS configurations ──────────────────────────────────────────────────
        nixosConfigurations = {
          nixos = inputs.nixpkgs.lib.nixosSystem {
            specialArgs = {inherit inputs;};
            modules = [
              ./nixos/configuration.nix
              inputs.catppuccin.nixosModules.catppuccin
              inputs.home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.backupFileExtension = "bak";
                home-manager.users = {inherit (inputs.self.homeModules) ray;};
              }
            ];
          };
        };

        # ── Darwin configurations ─────────────────────────────────────────────────
        darwinConfigurations.macbook = inputs.darwin.lib.darwinSystem {
          inherit inputs;
          system = "aarch64-darwin";
          specialArgs = {username = "ray";};
          modules = [
            {nixpkgs.overlays = overlays; nixpkgs.config.allowUnfree = true;}
            ./darwin.nix
            inputs.determinate.darwinModules.default
            inputs.home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = false;
              home-manager.backupFileExtension = "bak";
              home-manager.users = {inherit (inputs.self.homeModules) ray;};
            }
          ];
        };

        # ── Standalone Home Manager configurations ────────────────────────────────
        homeConfigurations = {
          linux = inputs.home-manager.lib.homeManagerConfiguration {
            pkgs = import inputs.nixpkgs {system = "x86_64-linux"; overlays = overlays; config.allowUnfree = true;};
            modules = [inputs.self.homeModules.ray];
          };
          darwin = inputs.home-manager.lib.homeManagerConfiguration {
            pkgs = import inputs.nixpkgs {system = "aarch64-darwin"; overlays = overlays; config.allowUnfree = true;};
            modules = [inputs.self.homeModules.ray];
          };
          termux = inputs.home-manager.lib.homeManagerConfiguration {
            pkgs = import inputs.nixpkgs {system = "aarch64-linux"; overlays = overlays; config.allowUnfree = true;};
            modules = [
              inputs.self.homeModules.ray
              {home.homeDirectory = "/data/data/com.termux.nix/files/home";}
            ];
          };
        };
      };
    };
}
