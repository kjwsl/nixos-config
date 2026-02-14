# Example: Flake Apps Approach for Your Dotfiles
# This is what your setup would look like WITHOUT home-manager

{
  description = "Ray's dotfiles - Flake Apps Approach";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};

      # Your dotfiles as a derivation
      dotfiles = pkgs.stdenv.mkDerivation {
        name = "ray-dotfiles";
        src = ./.;

        installPhase = ''
          mkdir -p $out/share/dotfiles

          # Copy all configs
          cp -r config/tmux $out/share/dotfiles/
          cp -r config/wezterm $out/share/dotfiles/
          cp starship.toml $out/share/dotfiles/

          # Fish config (you'd need to create this manually)
          mkdir -p $out/share/dotfiles/fish
          cp fish/config.fish $out/share/dotfiles/fish/  # Doesn't exist yet!
          cp fish/alias.fish $out/share/dotfiles/fish/
          cp fish/functions.fish $out/share/dotfiles/fish/
        '';
      };

      # Installation script
      install-script = pkgs.writeShellScriptBin "install-dotfiles" ''
        #!/usr/bin/env bash
        set -e

        DOTFILES="${dotfiles}/share/dotfiles"
        CONFIG_DIR="$HOME/.config"

        echo "📦 Installing dotfiles from: $DOTFILES"

        # Function to safely symlink
        safe_link() {
          local src=$1
          local dest=$2

          if [ -L "$dest" ]; then
            echo "  Removing old symlink: $dest"
            rm "$dest"
          elif [ -e "$dest" ]; then
            echo "  ⚠️  Backing up existing: $dest -> $dest.backup"
            mv "$dest" "$dest.backup"
          fi

          ln -sf "$src" "$dest"
          echo "  ✅ Linked: $dest -> $src"
        }

        # Create config directory
        mkdir -p "$CONFIG_DIR"

        # Symlink configs
        safe_link "$DOTFILES/tmux" "$CONFIG_DIR/tmux"
        safe_link "$DOTFILES/wezterm" "$CONFIG_DIR/wezterm"
        safe_link "$DOTFILES/fish" "$CONFIG_DIR/fish"
        safe_link "$DOTFILES/starship.toml" "$CONFIG_DIR/starship.toml"

        echo ""
        echo "✅ Dotfiles installed successfully!"
        echo ""
        echo "⚠️  NOTE: This only installed configs, not packages!"
        echo "You still need to install: fish, tmux, neovim, starship, etc."
        echo "Run: nix profile install .#packages"
      '';

      # Separate package bundle
      packages-bundle = pkgs.buildEnv {
        name = "ray-packages";
        paths = with pkgs; [
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

          # Tools
          bat
          eza
          yazi
          btop
          ripgrep
          fd
          jujutsu
          lazygit
          # ... all your other tools
        ];
      };

    in {
      # The dotfiles derivation
      packages.${system} = {
        dotfiles = dotfiles;
        packages = packages-bundle;
        default = packages-bundle;
      };

      # Install apps
      apps.${system} = {
        # Main installer
        default = {
          type = "app";
          program = "${install-script}/bin/install-dotfiles";
        };

        # Install only dotfiles
        dotfiles = {
          type = "app";
          program = "${install-script}/bin/install-dotfiles";
        };

        # Install only packages (separate)
        packages = {
          type = "app";
          program = "${pkgs.writeShellScript "install-packages" ''
            echo "📦 Installing packages..."
            nix profile install ${packages-bundle}
            echo "✅ Packages installed!"
          ''}";
        };
      };
    };
}
