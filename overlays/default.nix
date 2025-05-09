{ inputs, ... }:

let
  # Import all overlay files
  overlays = [
    # Development tools overlays
    (import ./dev-tools.nix)
    
    # Desktop environment overlays
    (import ./desktop-environments.nix)
    
    # Application overlays
    (import ./applications.nix)
  ];
in
{
  nixpkgs.overlays = overlays;
} 