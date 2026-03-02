{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

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

  outputs = {
    self,
    nixpkgs,
    darwin,
    home-manager,
    catppuccin,
    wrappers,
    ...
  }@inputs: let
    username = "ray";
    makeHome = system: username: homeDirectory: extraModules: let
      pkgs = import nixpkgs {
        inherit system;
      };
    in
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules =
          [
            ./home/home.nix
            catppuccin.homeModules.catppuccin
            {
              home.username = username;
              home.homeDirectory = homeDirectory;
            }
          ]
          ++ extraModules;
      };
  in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        ./nixos/configuration.nix
        
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "bak";
          home-manager.users.${username} = {
            imports = [
              ./home/home.nix
              catppuccin.homeModules.catppuccin
            ];
            home.homeDirectory = "/home/${username}";
          };
        }
      ];
    };

    darwinConfigurations.macbook = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = {inherit username;};
      modules = [
        ./darwin.nix

        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "bak"; # Backup existing files
          home-manager.users.${username} = {
            imports = [
              ./home/home.nix
              catppuccin.homeModules.catppuccin
            ];
            home.homeDirectory = "/Users/${username}";
          };
        }
      ];
    };
    
    homeConfigurations = {
      linux = makeHome "x86_64-linux" "ray" "/home/ray" [];
      darwin = makeHome "aarch64-darwin" "ray" "/Users/ray" [];
      termux = makeHome "aarch64-linux" "ray" "/data/data/com.termux.nix/files/home" [];
    };
  };
}
