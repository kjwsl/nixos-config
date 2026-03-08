# AI/ML stack — gated behind my.stacks.ai.enable.
{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.my.stacks.ai.enable {
    environment.systemPackages = with pkgs; [
      python3
      python3Packages.pytorch
      python3Packages.numpy
    ];
  };
}
