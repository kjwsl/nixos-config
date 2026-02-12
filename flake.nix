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
  };

  outputs = { self, nixpkgs, darwin, home-manager, ... }:
    let
      # Username Parameterization:
      # Automatically derives username from the USER environment variable,
      # falling back to "nixuser" if not set. This makes the configuration
      # shareable and usable by any user without hardcoding names.
      username =
        let envUser = builtins.getEnv "USER";
        in if envUser != "" then envUser else "nixuser";
      # Helper function to create home-manager configurations.
      # Takes system architecture, username, home directory path, and optional modules.
      # This abstraction allows creating multiple platform-specific configurations
      # while maintaining consistent parameterization.
      makeHome = system: username: homeDirectory: extraModules:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
          };
          modules = [
            ./home.nix
            {
              home.username = username;
              home.homeDirectory = homeDirectory;
            }
          ] ++ extraModules;
        };
    in
    {
      # Darwin (macOS) Configuration:
      # Uses the parameterized username to create a user-specific configuration.
      # The configuration name dynamically matches the current user.
      darwinConfigurations.${username} = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit username; };
        modules = [
          ./darwin.nix
          
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "bak"; # Backup existing files
            home-manager.users.${username} = {
              imports = [ ./home.nix ];
              home.homeDirectory = "/Users/${username}";
            };
          }
        ];
      };

      # Home Manager Configurations:
      # Generic configuration names (linux, darwin, termux) instead of user-specific names.
      # Each configuration uses the parameterized username and appropriate home directory path.
      # This approach allows any user to build with commands like:
      #   nix run home-manager -- build --flake .#linux
      # without needing to modify the flake or know the configuration name.
      homeConfigurations = {
        linux = makeHome "x86_64-linux" username "/home/${username}" [];
        darwin = makeHome "aarch64-darwin" username "/Users/${username}" [];
        termux = makeHome "aarch64-linux" username "/data/data/com.termux.nix/files/home" [];
      };

    };
}
