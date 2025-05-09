{ config, pkgs, ... }:

{
  imports = [
    ./hosts/nixos/default/configuration.nix
  ];
} 