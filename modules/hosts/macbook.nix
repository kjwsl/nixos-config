# Host: "macbook" — nix-darwin configuration (aarch64-darwin).
# Registers a deferredModule under configurations.darwin.macbook.
# Home Manager config is provided via flake.modules.homeManager.base.
{
  config,
  inputs,
  ...
}: {
  configurations.darwin.macbook.module = {pkgs, ...}: {
    imports = [
      inputs.determinate.darwinModules.default
      inputs.home-manager.darwinModules.home-manager
    ];

    nixpkgs.overlays = [
      inputs.neovim-nightly-overlay.overlays.default
      inputs.nur.overlays.default
    ];
    nixpkgs.config.allowUnfree = true;

    users.users.ray = {
      name = "ray";
      home = "/Users/ray";
      shell = pkgs.nushell;
    };

    homebrew = {
      enable = true;
      taps = ["BarutSRB/tap"];
      casks = [
        "battery"
        "sol"
        "discord"
        "floorp"
        "font-jetbrains-mono-nerd-font"
        "steam"
        "telegram-desktop"
        "thunderbird"
        "wezterm@nightly"
        "barutsrb/tap/omniwm"
      ];
    };

    system.defaults.dock.autohide = true;
    system.defaults.finder.AppleShowAllExtensions = true;

    system.activationScripts.postActivation.text = ''
      sudo nvram BootPreference=%00
    '';

    launchd.daemons.automountd = {
      serviceConfig = {
        Disabled = true;
        Label = "com.apple.automountd";
        ProgramArguments = ["/usr/sbin/automountd"];
      };
    };

    nix.settings.experimental-features = "nix-command flakes";

    programs.bash.interactiveShellInit = ''
      if ! [ "$TERM" = "dumb" ] && [ -z "$BASH_EXECUTION_STRING" ]; then
        exec nu
      fi
    '';

    programs.zsh.interactiveShellInit = ''
      if ! [ "$TERM" = "dumb" ] && [ -z "$ZSH_EXECUTION_STRING" ]; then
        exec nu
      fi
    '';

    determinateNix.enable = true;

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = false;
    home-manager.backupFileExtension = "bak";
    home-manager.users.ray = config.flake.modules.homeManager.base;

    system.stateVersion = 4;
    system.primaryUser = "ray";
  };
}
