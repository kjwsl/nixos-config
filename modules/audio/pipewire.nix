# PipeWire audio stack for NixOS desktop.
# Contributes to flake.modules.nixos.pc.
{...}: {
  flake.modules.nixos.pc = {
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
