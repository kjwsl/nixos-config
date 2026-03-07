# Gaming stack module.
#
# Enables: Steam, Lutris, MangoHud, GameMode.
# Options:
#   my.stacks.gaming.enable        — toggle the whole stack
#   my.stacks.gaming.openFirewall  — open Steam Remote Play / dedicated server ports
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.stacks.gaming;
in {
  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = cfg.openFirewall;
      dedicatedServer.openFirewall = cfg.openFirewall;
      gamescopeSession.enable = true;
    };

    programs.gamemode.enable = true;

    environment.systemPackages = with pkgs; [
      lutris
      mangohud
      heroic # Epic Games launcher
    ];

    # 32-bit OpenGL/Vulkan needed by most games
    hardware.graphics = {
      enable = lib.mkDefault true;
      enable32Bit = lib.mkDefault true;
    };

    nixpkgs.config.allowUnfree = lib.mkDefault true;
  };
}
