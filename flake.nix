{
  description = "A very basic flake";

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

  outputs = inputs @ {flake-parts, ...}: let
    overlays = [
      inputs.neovim-nightly-overlay.overlays.default
    ];
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      flake = {
        homeModules.ray = {
          pkgs,
          lib,
          ...
        }: {
          imports = [
            {
              nixpkgs.overlays = overlays;
            }
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

        nixosConfigurations.nixos = inputs.nixpkgs.lib.nixosSystem {
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

        darwinConfigurations.macbook = inputs.darwin.lib.darwinSystem {
          inherit inputs;
          system = "aarch64-darwin";
          specialArgs = {username = "ray";};
          modules = [
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

        homeConfigurations = {
          linux = inputs.home-manager.lib.homeManagerConfiguration {
            pkgs = import inputs.nixpkgs {system = "x86_64-linux";};
            modules = [inputs.self.homeModules.ray];
          };
          darwin = inputs.home-manager.lib.homeManagerConfiguration {
            pkgs = import inputs.nixpkgs {system = "aarch64-darwin";};
            modules = [inputs.self.homeModules.ray];
          };
          termux = inputs.home-manager.lib.homeManagerConfiguration {
            pkgs = import inputs.nixpkgs {system = "aarch64-linux";};
            modules = [
              inputs.self.homeModules.ray
              {home.homeDirectory = "/data/data/com.termux.nix/files/home";}
            ];
          };
        };
      };

      systems = ["aarch64-darwin" "x86_64-linux" "aarch64-linux"];
    };
}
