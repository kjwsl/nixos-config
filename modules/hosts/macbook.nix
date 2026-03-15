# Host: "macbook" — nix-darwin configuration (aarch64-darwin).
# Registers a deferredModule under configurations.darwin.macbook.
# Home Manager config is provided via flake.modules.homeManager.base.
{
  config,
  inputs,
  ...
}:
{
  configurations.darwin.macbook.module =
    {
      pkgs,
      lib,
      ...
    }:
    let
      defaultShell = pkgs.fish;
    in
    {
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
        name = "${config.username}";
        home = "/Users/${config.username}";
        shell = defaultShell;
      };

      homebrew = {
        enable = true; # this does not install homebrew
        taps = [ "BarutSRB/tap" ];
        casks = [
          "battery"
          "discord"
          "floorp"
          "font-jetbrains-mono-nerd-font"
          "steam"
          "telegram-desktop"
          "thunderbird"
          "wezterm@nightly"
          "barutsrb/tap/omniwm"
          "raycast"
        ];
        global = {
          brewfile = true; # Generates a Brewfile to `$HOMEBREW_BUNDLE_FILE`
        };
        onActivation = {
          # cleanup = "uninstall";
        };
        enableBashIntegration = true;
        enableZshIntegration = true;
        enableFishIntegration = true;

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
          ProgramArguments = [ "/usr/sbin/automountd" ];
        };
      };

      nix.settings = {
        experimental-features = "nix-command flakes";
        extra-substituters = [ "https://cache.numtide.com" ];
        extra-trusted-public-keys = [ "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=" ];
      };

      programs = {
        bash.interactiveShellInit =
          # zsh
          ''
            if ! [ "$TERM" = "dumb" ] && [ -z "$BASH_EXECUTION_STRING" ]; then
              exec "${lib.getExe defaultShell}"
            fi
          '';

        zsh.interactiveShellInit =
          # zsh
          ''
            if ! [ "$TERM" = "dumb" ] && [ -z "$ZSH_EXECUTION_STRING" ]; then
              exec "${lib.getExe defaultShell}"
            fi
          '';
        fish.enable = true;
      };

      determinateNix = {
        enable = true;
        determinateNixd = {
          garbageCollector.strategy = "automatic";
        };
      };

      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = false;
      home-manager.backupFileExtension = "bak";
      home-manager.extraSpecialArgs = { inherit inputs; };
      home-manager.users.ray = config.flake.modules.homeManager.base;

      nix.settings.auto-optimise-store = true;

      system.defaults.controlcenter.BatteryShowPercentage = true;

      system.keyboard.enableKeyMapping = true;
      system.keyboard.remapCapsLockToEscape = true;

      system.defaults.NSGlobalDomain.KeyRepeat = 2;
      system.defaults.NSGlobalDomain.InitialKeyRepeat = 15;

      system.stateVersion = 4;
      system.primaryUser = "${config.username}";
    };
}
