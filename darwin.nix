{ pkgs, username, ... }: 
{
    users.users.${username} = {
        name = username;
        home = "/Users/${username}";
        shell = pkgs.fish;
    };

    homebrew = {
        enable = true;

        taps = [];
        brews = [
            "mas"
        ];
        
        casks = [
            "brave-browser"
            "wezterm@nightly"
            "alfred"
            "aldente"
            "font-jetbrains-mono-nerd-font"
            "steam"
        ];
        onActivation.cleanup = "uninstall";
    };

    programs.fish.enable = true; # Enable fish program for nix-darwin

    system.defaults.dock.autohide = true;
    system.defaults.finder.AppleShowAllExtensions = true;

    

    nix.settings.experimental-features = "nix-command flakes";
    nix.enable = false;
    system.stateVersion = 4;
    system.primaryUser = username;
}
