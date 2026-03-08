# Music production stack — gated behind my.stacks.music.enable.
{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.my.stacks.music.enable {
    environment.systemPackages = with pkgs; [
      audacity
      ardour
    ];
  };
}
