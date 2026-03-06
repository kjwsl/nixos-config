{
  pkgs,
  username,
  inputs,
  ...
}: {
  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
    shell = pkgs.fish;
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

  programs.fish.enable = true; # Enable fish program for nix-darwin

  system.defaults.dock.autohide = true;
  system.defaults.finder.AppleShowAllExtensions = true;

  system.activationScripts.postActivation.text = ''
  # Prevent startup when opening the lid or connecting to power
  # %00 = Both, %01 = Lid Only, %02 = Power Only
  sudo nvram BootPreference=%00
'';

  nix.settings.experimental-features = "nix-command flakes";

# Use Determinate Nix 
  nix.enable = false;
  determinateNix.enable = true;

  system.stateVersion = 4;
  system.primaryUser = username;
}
