# Work profile module.
#
# Applied when `my.profile == "work"`:
#   - Overrides AI stack to the lighter "work" profile
#   - Disables gaming and music stacks by default
#   - Adds corporate Nix caches
{
  config,
  lib,
  ...
}: {
  config = lib.mkIf (config.my.profile == "work") {
    # Lighter AI stack for work machines
    my.stacks.ai.profile = lib.mkDefault "work";

    # Heavy entertainment stacks off unless explicitly enabled
    my.stacks.gaming.enable = lib.mkDefault false;
    my.stacks.music.enable = lib.mkDefault false;

    # Additional binary caches common in corporate environments
    nix.settings = {
      substituters = lib.mkAfter [
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = lib.mkAfter [
        "nix-community.cachix.org-1:mB9FSh9qf2dde0enkoOnkl2HlcSoWkSsaIwh6y/R0uo="
      ];
    };
  };
}
