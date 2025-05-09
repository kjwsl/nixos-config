{ config, lib, pkgs, ... }:

with lib;

{
  # Import submodules directly at the top level
  imports = [
    ./fish.nix
    ./zoxide.nix
    ./bat.nix
    ./eza.nix
    ./fastfetch.nix
  ];
  
  # No option declarations here - they are already defined in the individual module files
}
