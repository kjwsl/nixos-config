self: super: {
  # Override Firefox with custom settings
  firefox = super.firefox.override {
    extraPolicies = {
      # Enable custom policies
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
    };
  };

  # Override VSCode/Cursor with custom extensions
  vscode = super.vscode.override {
    extensions = with super.vscode-extensions; [
      # Language support
      ms-python.python
      rust-lang.rust-analyzer
      tamasfe.even-better-toml
      
      # Themes
      catppuccin.catppuccin-vsc
      
      # Utilities
      eamodio.gitlens
      esbenp.prettier-vscode
    ];
  };

  # Create a custom applications package
  my-apps = super.symlinkJoin {
    name = "my-apps";
    paths = with super; [
      # Browsers
      firefox
      chromium
      
      # Development
      vscode
      jetbrains.idea-ultimate
      
      # Communication
      discord
      telegram-desktop
      
      # Media
      spotify
      mpv
      
      # Utilities
      alacritty
      kitty
      rofi
    ];
  };

  # Override specific package versions
  spotify = super.spotify.overrideAttrs (old: {
    version = "1.2.3";  # Specify custom version
    src = super.fetchurl {
      url = "https://repository-origin.spotify.com/pool/non-free/s/spotify-client/spotify-client_${old.version}.deb";
      sha256 = "0000000000000000000000000000000000000000000000000000";
    };
  });
} 