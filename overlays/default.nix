# Package overlays.
# Currently applies the neovim nightly overlay globally.
# Add additional overlays here as needed.
{inputs, ...}: {
  nixpkgs.overlays = [
    inputs.neovim-nightly-overlay.overlays.default
  ];
}
