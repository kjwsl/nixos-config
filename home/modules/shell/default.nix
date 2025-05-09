{ config, lib, pkgs, ... }:
{
  imports = [
    ./bat.nix
    ./fish.nix
    ./zoxide.nix
    ./eza.nix
  ];
}
