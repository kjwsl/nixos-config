{ config, lib, pkgs, ... }:

let
  dotfilesDir = "${config.home.homeDirectory}/repos/home-manager/dotfiles";
in
{
  # ============================================================================
  # Mutable Config Symlinks
  # ============================================================================
  # These configs are symlinked to the repo, allowing direct editing
  # without home-manager rebuild. Still version-controlled!

  xdg.configFile = {
    # -------------------------------------------------------------------------
    # Editors (frequently edited)
    # -------------------------------------------------------------------------
    "nvim".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/nvim";

    # -------------------------------------------------------------------------
    # macOS-specific (frequently tweaked)
    # -------------------------------------------------------------------------
    "aerospace/aerospace.toml".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/aerospace/aerospace.toml";

    "karabiner".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/karabiner";

    "sketchybar".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/sketchybar";

    # -------------------------------------------------------------------------
    # Terminal emulators (frequently customized)
    # -------------------------------------------------------------------------
    "wezterm".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/wezterm";

    "ghostty".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/ghostty";

    "alacritty".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/alacritty";

    "kitty".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/kitty";

    # -------------------------------------------------------------------------
    # Multiplexers (frequently tweaked)
    # -------------------------------------------------------------------------
    "tmux".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/tmux";

    "zellij".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/zellij";
  };

  # Note: These directories must exist in the repo
  # Create placeholders with:
  #   mkdir -p ~/repos/home-manager/dotfiles/{nvim,aerospace,karabiner,sketchybar,wezterm,ghostty,alacritty,kitty,tmux,zellij}
}
