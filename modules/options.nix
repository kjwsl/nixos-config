# Shared top-level options used across NixOS modules.
# Import this in any NixOS module that needs to read or set my.* options.
{lib, ...}: {
  options.my = {
    profile = lib.mkOption {
      type = lib.types.enum ["desktop" "work" "minimal"];
      default = "desktop";
      description = ''
        System-wide profile. Controls stack defaults and cross-module behaviour.

          "desktop"  — full graphical environment, all stacks available
          "work"     — lighter CUDA, no gaming, company git email applied
          "minimal"  — headless / server, no heavy stacks
      '';
    };

    stacks = {
      ai = {
        enable = lib.mkEnableOption "AI/ML stack (python, pytorch, jupyter, tensorflow, cudatoolkit)";

        profile = lib.mkOption {
          type = lib.types.enum ["desktop" "work" "minimal"];
          default = "desktop";
          description = "AI stack variant: desktop includes jupyter, work is slimmer, minimal is CPU-only.";
        };

        excludes = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [];
          description = "Packages to exclude from the AI stack (filtered by reference equality).";
        };

        overrides = lib.mkOption {
          type = lib.types.attrsOf lib.types.anything;
          default = {};
          description = "Arbitrary attribute overrides merged into the AI stack environment.";
        };
      };

      music = {
        enable = lib.mkEnableOption "Music production stack (supercollider, ardour, audacity)";
      };

      gaming = {
        enable = lib.mkEnableOption "Gaming stack (steam, lutris, mangohud)";

        openFirewall = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Open firewall ports for Steam Remote Play and dedicated server hosting.";
        };
      };
    };
  };
}
