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

      # Home Manager Configurations with Profile Support:
      # Multiple profiles available for different use cases:
      #   minimal     - Just shell and basic tools
      #   development - Full dev environment (default)
      #   work        - Development + work-specific tools
      #   personal    - Development + personal tools
      #
      # Usage:
      #   home-manager switch --flake .#darwin-development (or just .#darwin for default)
      #   home-manager switch --flake .#darwin-minimal
      #   home-manager switch --flake .#darwin-work
      homeConfigurations = {
        # macOS configurations
        darwin = makeHome "aarch64-darwin" username "/Users/${username}" [ ./profiles/development.nix ];
        darwin-minimal = makeHome "aarch64-darwin" username "/Users/${username}" [ ./profiles/minimal.nix ];
        darwin-development = makeHome "aarch64-darwin" username "/Users/${username}" [ ./profiles/development.nix ];
        darwin-work = makeHome "aarch64-darwin" username "/Users/${username}" [ ./profiles/work.nix ];
        darwin-personal = makeHome "aarch64-darwin" username "/Users/${username}" [ ./profiles/personal.nix ];

        # Linux configurations
        linux = makeHome "x86_64-linux" username "/home/${username}" [ ./profiles/development.nix ];
        linux-minimal = makeHome "x86_64-linux" username "/home/${username}" [ ./profiles/minimal.nix ];
        linux-development = makeHome "x86_64-linux" username "/home/${username}" [ ./profiles/development.nix ];
        linux-work = makeHome "x86_64-linux" username "/home/${username}" [ ./profiles/work.nix ];
        linux-personal = makeHome "x86_64-linux" username "/home/${username}" [ ./profiles/personal.nix ];

        # Termux configurations
        termux = makeHome "aarch64-linux" username "/data/data/com.termux.nix/files/home" [ ./profiles/minimal.nix ];
        termux-development = makeHome "aarch64-linux" username "/data/data/com.termux.nix/files/home" [ ./profiles/development.nix ];
      };

    };
}
