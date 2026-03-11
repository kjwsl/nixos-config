# Neovim configuration sourced from the nvim-config flake input.
# To update: nix flake update nvim-config
{inputs, ...}: {
  flake.modules.homeManager.base = {
    home.file.".config/nvim" = {
      source = inputs.nvim-config;
      recursive = true;
    };
  };
}
