# Enables the flake-parts modules registry so that flake.modules.* options
# are available for storing deferredModules used by nixos/darwin/home builders.
# https://flake.parts/options/flake-parts-modules.html
{inputs, ...}: {
  imports = [inputs.flake-parts.flakeModules.modules];
}
