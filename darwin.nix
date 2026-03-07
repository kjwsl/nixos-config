{
  pkgs,
  username,
  inputs,
  ...
}: {
  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
    shell = pkgs.nushell;
  };

  homebrew = {
    enable = true;

    taps = [
      "BarutSRB/tap" # OmniWM
    ];

    casks = [
      "battery" # or aldente
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
    # onActivation.cleanup = "uninstall";
  };

  system.defaults.dock.autohide = true;
  system.defaults.finder.AppleShowAllExtensions = true;

  system.activationScripts.postActivation.text = ''
    # Prevent startup when opening the lid or connecting to power
    # %00 = Both, %01 = Lid Only, %02 = Power Only
    sudo nvram BootPreference=%00
  '';

  launchd.daemons = {
    # Disable automount so that weird `opendirectoryd` consuming high CPU won't happen
    automountd = {
      serviceConfig = {
        Disabled = true;
        Label = "com.apple.automountd";
        ProgramArguments = ["/usr/sbin/automountd"]; # optional, but matches original
        # No need for more; disabling prevents launchd from starting it
      };
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

  # Use Determinate Nix
  determinateNix.enable = true;

  system.stateVersion = 4;
  system.primaryUser = username;
}
