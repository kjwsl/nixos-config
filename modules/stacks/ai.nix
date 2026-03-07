# AI/ML stack module.
#
# Options:
#   my.stacks.ai.enable            — toggle the whole stack
#   my.stacks.ai.profile           — "desktop" | "work" | "minimal"
#   my.stacks.ai.excludes          — list of packages to drop (matched by reference)
#   my.stacks.ai.overrides         — arbitrary attrs merged into the environment
#
# Default packages: python3, pytorch, jupyter, tensorflow, cudatoolkit
# Profile variants:
#   desktop  — full suite + jupyter notebook
#   work     — lighter CUDA, no heavy GUI notebooks
#   minimal  — CPU-only python stack, no CUDA
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.stacks.ai;

  # Packages always included (filtered by excludes below)
  basePackages = with pkgs; [
    python3
  ];

  # Profile-specific additions on top of base
  profilePackages =
    {
      desktop = with pkgs; [
        cudatoolkit
        (python3.withPackages (ps:
          with ps; [
            torch
            torchvision
            jupyter
            tensorflow
          ]))
      ];
      work = with pkgs; [
        (python3.withPackages (ps:
          with ps; [
            torch
            jupyter
          ]))
      ];
      minimal = with pkgs; [
        (python3.withPackages (ps:
          with ps; [
            numpy
            scipy
          ]))
      ];
    }
    .${cfg.profile};

  # Merge base + profile, then filter by excludes
  allPackages = basePackages ++ profilePackages;
  filteredPackages = builtins.filter (pkg: !(builtins.elem pkg cfg.excludes)) allPackages;
in {
  config = lib.mkIf cfg.enable {
    environment.systemPackages = filteredPackages;

    # CUDA hardware acceleration (non-minimal profiles)
    hardware.graphics.enable = lib.mkIf (cfg.profile != "minimal") (lib.mkDefault true);
    hardware.graphics.enable32Bit = lib.mkIf (cfg.profile != "minimal") (lib.mkDefault true);

    nixpkgs.config.allowUnfree = lib.mkDefault true;
  };
}
