# Gaming stack — gated behind my.stacks.gaming.enable.
{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.my.stacks.gaming.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = config.my.stacks.gaming.openFirewall;
      dedicatedServer.openFirewall = config.my.stacks.gaming.openFirewall;
    };

    environment.systemPackages = with pkgs; [
      lutris
      mangohud
      gamemode
    ];
  };
}
