# Clean Flake Approach - Dotfiles as Packages
# Inspired by: https://github.com/fabioluciano/tmux-powerkit
{
  description = "Ray's dotfiles - Clean package-based approach";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      # Dotfiles as packages
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          # Fish configuration package
          fish-config = pkgs.stdenvNoCC.mkDerivation {
            name = "fish-config";
            src = ./config/fish;
            installPhase = ''
              mkdir -p $out/share/fish
              cp -r * $out/share/fish/
            '';
          };

          # Tmux configuration package
          tmux-config = pkgs.stdenvNoCC.mkDerivation {
            name = "tmux-config";
            src = ./config/tmux;
            installPhase = ''
              mkdir -p $out/share/tmux
              cp -r * $out/share/tmux/
            '';
          };

          # WezTerm configuration package
          wezterm-config = pkgs.stdenvNoCC.mkDerivation {
            name = "wezterm-config";
            src = ./config/wezterm;
            installPhase = ''
              mkdir -p $out/share/wezterm
              cp -r * $out/share/wezterm/
            '';
          };

          # Starship configuration package
          starship-config = pkgs.stdenvNoCC.mkDerivation {
            name = "starship-config";
            src = ./starship.toml;
            dontUnpack = true;
            installPhase = ''
              mkdir -p $out/share
              cp $src $out/share/starship.toml
            '';
          };

          # Combined dotfiles package
          dotfiles = pkgs.symlinkJoin {
            name = "dotfiles";
            paths = [
              self.packages.${system}.fish-config
              self.packages.${system}.tmux-config
              self.packages.${system}.wezterm-config
              self.packages.${system}.starship-config
            ];
          };

          # Tools bundle (separate from dotfiles!)
          tools = pkgs.buildEnv {
            name = "ray-tools";
            paths = with pkgs; [
              fish
              tmux
              starship
              neovim
              bat
              eza
              ripgrep
              fd
              jujutsu
              # All your other tools
            ];
          };

          # Combined: dotfiles + tools
          default = pkgs.symlinkJoin {
            name = "ray-environment";
            paths = [
              self.packages.${system}.dotfiles
              self.packages.${system}.tools
            ];
          };
        }
      );

      # Overlays for integration
      overlays.default = final: prev: {
        ray-dotfiles = self.packages.${final.system}.dotfiles;
        ray-tools = self.packages.${final.system}.tools;
      };

      # Dev shells for different profiles
      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          # Minimal shell
          minimal = pkgs.mkShell {
            packages = with pkgs; [
              fish
              git
              starship
            ];
            shellHook = ''
              # Link dotfiles
              mkdir -p $HOME/.config
              ln -sf ${self.packages.${system}.fish-config}/share/fish $HOME/.config/fish
              ln -sf ${self.packages.${system}.starship-config}/share/starship.toml $HOME/.config/starship.toml

              echo "✅ Minimal environment loaded"
              exec fish
            '';
          };

          # Development shell
          default = pkgs.mkShell {
            packages = with pkgs; [
              # Shell
              fish
              starship
              zoxide
              fzf

              # Editors
              neovim

              # Multiplexers
              tmux

              # Tools
              bat
              eza
              ripgrep
              fd
              jujutsu
              lazygit
            ];
            shellHook = ''
              # Link all dotfiles
              mkdir -p $HOME/.config
              ln -sf ${self.packages.${system}.fish-config}/share/fish $HOME/.config/fish
              ln -sf ${self.packages.${system}.tmux-config}/share/tmux $HOME/.config/tmux
              ln -sf ${self.packages.${system}.wezterm-config}/share/wezterm $HOME/.config/wezterm
              ln -sf ${self.packages.${system}.starship-config}/share/starship.toml $HOME/.config/starship.toml

              echo "✅ Development environment loaded"
              exec fish
            '';
          };

          # Work shell
          work = pkgs.mkShell {
            packages = with pkgs; [
              # Everything from default
            ] ++ (with pkgs; [
              # Work-specific
              slack
              docker
            ]);
            shellHook = ''
              # Same as default + work env vars
              export WORK_MODE=true
              exec fish
            '';
          };
        }
      );

      # Apps for installation
      apps = forAllSystems (system: {
        default = {
          type = "app";
          program = "${pkgs.writeShellScript "install-dotfiles" ''
            #!/bin/sh
            echo "📦 Installing dotfiles..."

            # Install the dotfiles package to profile
            nix profile install ${self}#dotfiles

            # Link configs
            mkdir -p ~/.config
            DOTFILES=$(nix profile list | grep dotfiles | awk '{print $4}')
            ln -sf $DOTFILES/share/fish ~/.config/fish
            ln -sf $DOTFILES/share/tmux ~/.config/tmux
            ln -sf $DOTFILES/share/wezterm ~/.config/wezterm
            ln -sf $DOTFILES/share/starship.toml ~/.config/starship.toml

            echo "✅ Dotfiles installed!"
            echo ""
            echo "To install tools: nix profile install ${self}#tools"
          ''}";
        };
      });
    };
}
