# Simplest Approach - Just devShells
# This is what many modern Nix users prefer
{
  description = "Ray's environment - devShell approach";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      # Just export your packages
      packages.${system} = {
        # Individual config packages
        fish-config = pkgs.runCommand "fish-config" {} ''
          mkdir -p $out/config/fish
          cp -r ${./config/fish}/* $out/config/fish/
        '';

        tmux-config = pkgs.runCommand "tmux-config" {} ''
          mkdir -p $out/config/tmux
          cp -r ${./config/tmux}/* $out/config/tmux/
        '';
      };

      # Development environments
      devShells.${system} = {
        # Default: full dev environment
        default = pkgs.mkShell {
          name = "dev";

          buildInputs = with pkgs; [
            # Shell
            fish
            starship
            zoxide
            fzf
            atuin

            # Multiplexers
            tmux
            zellij

            # Editors
            neovim

            # CLI tools
            bat
            eza
            ripgrep
            fd
            jujutsu
            lazygit
            git-absorb
            gitui

            # Development
            rustup
            mise
            just

            # All your tools...
          ];

          shellHook = ''
            # Auto-link configs from this repo
            export XDG_CONFIG_HOME=$PWD/config
            export STARSHIP_CONFIG=$PWD/starship.toml

            echo "🚀 Dev environment loaded"
            echo "📁 Configs from: $PWD"

            # Start fish if available
            [ -x "$(command -v fish)" ] && exec fish
          '';
        };

        # Minimal: just essentials
        minimal = pkgs.mkShell {
          buildInputs = with pkgs; [ fish git starship bat eza ripgrep ];
          shellHook = ''
            export XDG_CONFIG_HOME=$PWD/config
            echo "⚡ Minimal shell loaded"
            exec fish
          '';
        };

        # Work: dev + work tools
        work = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Include default tools
            fish starship neovim tmux
            # Plus work-specific
            docker
            kubectl
          ];
          shellHook = ''
            export WORK_MODE=true
            export XDG_CONFIG_HOME=$PWD/config
            exec fish
          '';
        };
      };

      # Formatter
      formatter.${system} = pkgs.nixpkgs-fmt;
    };
}
