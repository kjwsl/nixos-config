# Pattern: Custom Tmux Plugins from GitHub

## Implementation
```nix
let
  plugin = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "name";
    version = "unstable-YYYY-MM-DD";
    src = pkgs.fetchFromGitHub {
      owner = "owner";
      repo = "repo";
      rev = "commit-hash";
      sha256 = "sha256-...";
    };
    rtpFilePath = "script.tmux";
  };
in
```

## Get Hash
```bash
nix flake prefetch github:owner/repo
```

## Success: tmux-powerkit
Integrated 42-plugin framework as custom Nix plugin.
