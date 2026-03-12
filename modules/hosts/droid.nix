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
      config = {
        imports = [config.flake.modules.homeManager.base];
        home.homeDirectory = pkgs.lib.mkForce "/data/data/com.termux.nix/files/home";
      };
      backupFileExtension = "bak";
      useGlobalPkgs = true;
      extraSpecialArgs = {
        inherit inputs;
        isAndroid = true;
      };
    };

    nix.extraOptions = ''
      experimental-features = nix-command flakes
      sandbox = false
      use-pty = false
    '';

    system.stateVersion = "24.05";
  };
}
