{ inputs, ... }:
{
  mkDarwin = { hostname ? "rays-MacBook-Air", user ? "ray", profile ? "desktop" }: {
    hostname = inputs.nix-darwin.lib.darwinSystem { };

  };
}
