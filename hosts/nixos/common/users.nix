{ config, pkgs, lib, ... }:

{
  users.users.ray = {
    isNormalUser = true;
    description = "ray";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = lib.mkDefault pkgs.fish;
  };
} 