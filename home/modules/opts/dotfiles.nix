{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.larp.opts.dotfiles;
  dotfiles = builtins.fetchGit {
    url = "${cfg.gitUrl}";
    ref = "master";
    submodules = true;
    allRefs = true;
  };

  dotfilesList = [
    ".bashrc"
    ".zshrc"
    ".gitconfig"
    ".config/nvim"
    ".config/gh"
    ".config/wezterm"
  ];
  sourcePath = "${config.home.homeDirectory}/github/.dotfiles";

  mkDotfile = file: {
    source = "${dotfiles}/${file}";
  };

  dotfilesAttrs = builtins.listToAttrs (map (file: { name = file; value = mkDotfile file; }) dotfilesList);

  home.activation.prepareDotfiles = {
    text = ''
        echo "----> Setting up dotfiles..."

      # Variables
      DOTFILES_PATH="${config.custom.dotfiles.path}"

      # Ensure the repository exists
      if [ ! -d "${DOTFILES_PATH}/.git" ]; then
        echo "Dotfiles repository not found at ${DOTFILES_PATH}. Please clone it manually."
        exit 1
      fi

      # Initialize and update submodules
      echo "Initializing and updating git submodules..."
      cd "${DOTFILES_PATH}" || exit 1
      git submodule update --init --recursive

      # Function to symlink files
      symlink_file() {
        local src="$1"
        local dest="$2"

        if [ -L "${dest}" ]; then
          echo "Symlink already exists for $(basename "${dest}"), skipping."
        elif [ -e "${dest}" ]; then
          echo "File $(basename "${dest}") exists, backing up to $(basename "${dest}").backup"
          mv "${dest}" "${dest}.backup"
          ln -s "${src}" "${dest}"
          echo "Created symlink for $(basename "${dest}")."
        else
          ln -s "${src}" "${dest}"
          echo "Created symlink for $(basename "${dest}")."
        fi
      }

      # Iterate over all files and directories in the repository
      find "${DOTFILES_PATH}" -mindepth 1 | while read -r file; do
        fname=$(realpath --relative-to="${DOTFILES_PATH}" "${file}")
        target="${HOME}/${fname}"

        if [ -d "${file}" ]; then
          echo "Ensuring directory $(dirname "${target}") exists..."
          mkdir -p "${target}"
        elif [ -f "${file}" ]; then
          # Exclude specific files if necessary
          case "$(basename "${file}")" in
            ".gitignore" | ".DS_Store")
              echo "Excluding $(basename "${file}") from symlinking."
              ;;
            *)
              symlink_file "${file}" "${target}"
              ;;
          esac
        fi
      done

      echo "----> Dotfiles setup complete."
    '';
  };

in
{
  options.larp.opts.dotfiles =
    {
      enable = mkEnableOption "dotfiles";
      gitUrl = mkOption {
        type = types.str;
        default = "https://github.com/kjwsl/.dotfiles";
      };
      path = mkOption
        {
          type = types.path;
          default = sourcePath;
        };
    };

  config = mkIf cfg.enable
    {
      home.packages = [ pkgs.git ];
      home.file = dotfilesAttrs;
    };
}


