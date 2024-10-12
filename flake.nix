{
  description = "My Configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin.url = "github:lnl7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    sops-nix.url = "github:Mic92/sops-nix";
    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";

    # nixvim = {
    #
    #   url = "github:nix-community/nixvim";
    #   # If you are not running an unstable channel of nixpkgs, select the corresponding branch of nixvim.
    #   # url = "github:nix-community/nixvim/nixos-24.05";
    #
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };


  outputs = { nixpkgs, home-manager, nix-darwin, sops-nix, neovim-nightly, ... }@inputs:
    let
      lib = nixpkgs.lib;
      configDir = toString ./. + "/config/.config";
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      mkHome = { user, system }: {
        user = home-manager.lib.homeManagerConfiguration
          {
            pkgs = nixpkgs.legacyPackages.${system};
            extraSpecialArgs = { inherit inputs; };
            modules = [
              ./home/home.nix
            ];
          };
      };

      # { system = []}
      mkHomes = users:
        map
          (user:
            forAllSystems (system:
              mkHome { inherit user system; }
            )
          )
          users;

    in
    {
      # Your custom packages and modifications, exported as overlays

      homeConfigurations."ray" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages."aarch64-darwin";
        extraSpecialArgs = { inherit inputs; };
        modules = [
          ./home/home.nix
        ];
      };
      # homeConfigurations = mkHomes [
      #   "ray"
      #   "wow"
      # ];
      # homeConfigurations."macbook" = home-manager.lib.homeManagerConfiguration {
      #   pkgs = nixpkgs.legacyPackages."aarch64-darwin";
      #   extraSpecialArgs = { inherit inputs; };
      #   modules = [
      #     ./home/home.nix
      #   ];
      # };
      #
      darwinConfigurations."rays-MacBook-Air" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          { nixpkgs.config.allowUnfree = true; }
          ./hosts/darwin/darwin-configuration.nix
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              # useGlobalPkgs = true;
              useUserPackages = true;
              users.ray = import ./home/home.nix;
              extraSpecialArgs = { inherit inputs; inherit configDir; };
              backupFileExtension = "backup";
            };
            users.users.ray.home = nixpkgs.lib.mkForce "/Users/ray";
          }
        ];
        specialArgs = {
          inherit inputs;
          inherit configDir;
        };
      };
      nixosConfigurations = {
        default = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/nixos/configuration.nix
          ];
        };
        workmachine = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/workmachine/configuration.nix
          ];
        };
      };

    };
  # outputs
}
