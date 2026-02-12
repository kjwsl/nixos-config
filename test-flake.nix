{
  description = "Minimal test flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    {
      homeConfigurations = {
        test = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { system = "aarch64-darwin"; };
          modules = [
            ./minimal-test.nix
            {
              home.username = "ray";
              home.homeDirectory = "/Users/ray";
            }
          ];
        };
      };
    };
}