{
  description = "Cross-platform NixOS and nix-darwin configuration";

  inputs = {
    # Core inputs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Darwin support
    nix-darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Additional inputs
    flake-utils.url = "github:numtide/flake-utils";
    sops-nix.url = "github:Mic92/sops-nix";
    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nix-darwin, flake-utils, sops-nix, neovim-nightly, devshell, ... }@inputs:
    let
      lib = nixpkgs.lib;
      
      # Configuration directory
      configDir = toString ./. + "/config/.config";
      
      # Helper to get absolute paths
      getPath = path: builtins.toString (builtins.path { path = ./. + "/${path}"; });

      # Home Manager configuration builder
      mkHome = { user, system }:
        let
          pkgs = nixpkgs.legacyPackages."${system}";
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit inputs; };
          modules = [
            ./home/home.nix
          ];
        };

      # NixOS configuration builder
      mkNixosConfig = { system, hostname }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs system devshell; };
          modules = [
            ./hosts/nixos/${hostname}/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit inputs; };
                users.ray = ./home/home.nix;
                backupFileExtension = "backup";
              };
            }
          ];
        };
        
      # Darwin configuration builder  
      mkDarwinConfig = { system, hostname }:
        nix-darwin.lib.darwinSystem {
          inherit system;
          specialArgs = { inherit inputs configDir; };
          modules = [
            { 
              # Basic nixpkgs config
              nixpkgs.config.allowUnfree = true;
            }
            ./hosts/darwin/darwin-configuration.nix
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useUserPackages = true;
                users.ray = import ./home/home.nix;
                extraSpecialArgs = { inherit inputs configDir; };
                backupFileExtension = "backup";
              };
              users.users.ray.home = nixpkgs.lib.mkForce "/Users/ray";
            }
          ];
        };
    in
    {
      # Custom overlays
      overlays = [
        devshell.overlays.default
      ];

      # Home Manager standalone configurations
      homeConfigurations = {
        default = mkHome {
          user = "ray";
          system = "x86_64-linux";
        };
        mac = mkHome {
          user = "ray";
          system = "aarch64-darwin";
        };
      };

      # Darwin configurations
      darwinConfigurations = {
        "rays-MacBook-Air" = mkDarwinConfig {
          system = "aarch64-darwin";
          hostname = "rays-MacBook-Air";
        };
      };

      # NixOS configurations
      nixosConfigurations = {
        default = mkNixosConfig {
          system = "x86_64-linux";
          hostname = "default";
        };
        workmachine = mkNixosConfig {
          system = "x86_64-linux";
          hostname = "workmachine";
        };
      };

      # Development shells
      devShells = {
        default = nixpkgs.legacyPackages."x86_64-linux".mkShell {
          buildInputs = with nixpkgs.legacyPackages."x86_64-linux"; [
            devshell.packages."x86_64-linux".default
          ];
        };
      };
    };
}
