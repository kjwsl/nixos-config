# Host: "phone" — nix-on-droid configuration (aarch64-linux).
# Registers a deferredModule under configurations.nixOnDroid.phone.
# Home Manager config is provided via flake.modules.homeManager.base.
{
  config,
  inputs,
  ...
}: {
  configurations.nixOnDroid.phone.module = {pkgs, ...}: {
    environment.packages = with pkgs; [
      git
      nushell
      neovim
      curl
      wget
      gnupg
      openssh
    ];

    home-manager = {
      config = config.flake.modules.homeManager.base;
      backupFileExtension = "bak";
      useGlobalPkgs = true;
      extraSpecialArgs = {inherit inputs;};
    };

    # Override homeDirectory for nix-on-droid's path
    home-manager.config = {
      home.homeDirectory = pkgs.lib.mkForce "/data/data/com.termux.nix/files/home";
    };

    system.stateVersion = "24.05";
  };
}
