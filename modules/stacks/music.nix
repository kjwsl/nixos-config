# Music production stack module.
#
# Enables: supercollider, ardour, audacity, carla plugin host.
# Also configures real-time audio scheduling via JACK/PipeWire and PAM limits.
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.stacks.music;
in {
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      supercollider
      ardour
      audacity
      carla # Plugin host (LV2, VST, JACK)
    ];

    # JACK support through PipeWire
    services.pipewire.jack.enable = true;

    # Real-time audio scheduling
    security.rtkit.enable = true;

    security.pam.loginLimits = [
      {
        domain = "@audio";
        item = "rtprio";
        type = "-";
        value = "95";
      }
      {
        domain = "@audio";
        item = "memlock";
        type = "-";
        value = "unlimited";
      }
    ];

    users.groups.audio = {};
  };
}
