{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.ray.home.profile;
in
{
  import = [
    ./desktop
  ];

  option.ray.home.profile = mkOption {
    type = types.string;
    default = "desktop";

  };
}
