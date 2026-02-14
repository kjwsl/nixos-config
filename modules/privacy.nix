{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.privacy;
in
{
  options.services.privacy = {
    enable = mkEnableOption "privacy and anonymity tools";

    i2p = {
      enable = mkEnableOption "I2P (Invisible Internet Project)";

      httpProxy = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable HTTP proxy";
        };
        port = mkOption {
          type = types.int;
          default = 4444;
          description = "HTTP proxy port";
        };
      };

      socksProxy = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable SOCKS proxy";
        };
        port = mkOption {
          type = types.int;
          default = 4447;
          description = "SOCKS proxy port";
        };
      };
    };

    v2ray = {
      enable = mkEnableOption "V2Ray proxy";

      useV2RayA = mkOption {
        type = types.bool;
        default = true;
        description = "Use V2RayA GUI instead of raw V2Ray service";
      };
    };
  };

  config = mkMerge [
    # I2P Configuration
    (mkIf (cfg.enable && cfg.i2p.enable) {
      home.packages = with pkgs; [
        i2pd  # I2P daemon
      ];

      # On NixOS, you would use services.i2pd, but for home-manager
      # we'll provide instructions and manual setup
      home.file.".config/i2pd/i2pd.conf".text = ''
        # I2P Daemon Configuration (home-manager)
        # For system-wide setup on NixOS, use services.i2pd instead

        [http]
        enabled = ${if cfg.i2p.httpProxy.enable then "true" else "false"}
        address = 127.0.0.1
        port = ${toString cfg.i2p.httpProxy.port}

        [httpproxy]
        enabled = ${if cfg.i2p.httpProxy.enable then "true" else "false"}
        address = 127.0.0.1
        port = ${toString cfg.i2p.httpProxy.port}

        [socksproxy]
        enabled = ${if cfg.i2p.socksProxy.enable then "true" else "false"}
        address = 127.0.0.1
        port = ${toString cfg.i2p.socksProxy.port}

        [sam]
        enabled = true
        address = 127.0.0.1
        port = 7656
      '';

      home.file.".local/bin/i2p-start".source = pkgs.writeShellScript "i2p-start" ''
        #!/usr/bin/env bash
        # Start I2P daemon
        mkdir -p ~/.local/share/i2pd
        ${pkgs.i2pd}/bin/i2pd --conf=$HOME/.config/i2pd/i2pd.conf --datadir=$HOME/.local/share/i2pd
      '';

      home.file.".local/bin/i2p-start".executable = true;
    })

    # V2Ray Configuration
    (mkIf (cfg.enable && cfg.v2ray.enable) {
      home.packages = with pkgs; [
        (if cfg.v2ray.useV2RayA then v2raya else v2ray)
      ];

      # V2RayA provides a web UI at http://localhost:2017
      home.file.".local/bin/v2ray-start".source = pkgs.writeShellScript "v2ray-start" ''
        #!/usr/bin/env bash
        ${if cfg.v2ray.useV2RayA then ''
          # Start V2RayA (web UI at http://localhost:2017)
          echo "Starting V2RayA..."
          echo "Web UI will be available at: http://localhost:2017"
          ${pkgs.v2raya}/bin/v2raya
        '' else ''
          # Start V2Ray with config
          if [ ! -f "$HOME/.config/v2ray/config.json" ]; then
            echo "Error: V2Ray config not found at ~/.config/v2ray/config.json"
            echo "Create your config file first or use V2RayA (set useV2RayA = true)"
            exit 1
          fi
          ${pkgs.v2ray}/bin/v2ray run -c "$HOME/.config/v2ray/config.json"
        ''}
      '';

      home.file.".local/bin/v2ray-start".executable = true;
    })

    # Usage instructions
    (mkIf cfg.enable {
      home.file.".config/privacy-tools/README.md".text = ''
        # Privacy Tools Setup

        ## I2P (Invisible Internet Project)
        ${if cfg.i2p.enable then ''
        **Status**: Enabled

        ### Starting I2P
        ```bash
        i2p-start
        ```

        ### Proxy Settings
        - HTTP Proxy: localhost:${toString cfg.i2p.httpProxy.port}
        - SOCKS Proxy: localhost:${toString cfg.i2p.socksProxy.port}

        ### Browser Configuration
        Configure your browser to use the SOCKS proxy for .i2p domains:
        1. Firefox: Settings → Network Settings → Manual proxy
        2. Set SOCKS Host: localhost, Port: ${toString cfg.i2p.socksProxy.port}
        3. Select "SOCKS v5"

        ### System-wide I2P (NixOS only)
        If on NixOS, consider using `services.i2pd` in configuration.nix instead:
        ```nix
        services.i2pd = {
          enable = true;
          enableIPv4 = true;
          bandwidth = 256;
        };
        ```
        '' else "**Status**: Disabled (set services.privacy.i2p.enable = true)"}

        ## V2Ray
        ${if cfg.v2ray.enable then ''
        **Status**: Enabled (${if cfg.v2ray.useV2RayA then "V2RayA GUI" else "Raw V2Ray"})

        ### Starting V2Ray
        ```bash
        v2ray-start
        ```

        ${if cfg.v2ray.useV2RayA then ''
        ### V2RayA Web UI
        After starting, access the web interface at:
        **http://localhost:2017**

        Configure your proxies through the GUI.
        '' else ''
        ### Configuration
        Create your V2Ray config at: `~/.config/v2ray/config.json`

        Example config structure:
        ```json
        {
          "inbounds": [{ "port": 1080, "protocol": "socks" }],
          "outbounds": [{ "protocol": "vmess", "settings": {...} }]
        }
        ```
        ''}

        ### System-wide V2Ray (NixOS only)
        If on NixOS, use `services.v2ray`:
        ```nix
        services.v2ray = {
          enable = true;
          config = {
            # your config here
          };
        };
        ```
        '' else "**Status**: Disabled (set services.privacy.v2ray.enable = true)"}

        ## Quick Start
        1. Start the service you need: `i2p-start` or `v2ray-start`
        2. Configure your browser/system to use the proxies
        3. Test connectivity

        ## Systemd User Services (Advanced)
        To run these as background services:
        ```bash
        # Create systemd user service
        systemctl --user enable --now i2p.service
        ```

        ## Documentation
        - I2P: https://geti2p.net/
        - V2Ray: https://www.v2ray.com/
        - V2RayA: https://v2raya.org/
      '';
    })
  ];
}
