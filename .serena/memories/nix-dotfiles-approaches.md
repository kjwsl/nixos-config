# Nix Dotfiles Management Approaches - Knowledge Base

## Comparison Matrix

| Approach | Complexity | Package Mgmt | Profiles | Rollback | Best For |
|----------|-----------|--------------|----------|----------|----------|
| Home-Manager | High | ✅ Built-in | ✅ Easy | ✅ Generations | System-wide, multi-user |
| devShells | Low | ✅ Per-shell | ✅ Multiple | ❌ No | Per-project, modern |
| Pure Packages | Medium | ⚠️ Separate | ⚠️ Manual | ❌ No | Shareable libs |
| Flake Apps | Low | ⚠️ Separate | ⚠️ Manual | ❌ No | Simple installs |
| Hybrid | Medium | ✅ Mixed | ✅ Flexible | ⚠️ Partial | Best balance |

## Recommendations by Use Case

- **Single user, single machine**: devShells (simple, modern)
- **Multiple machines**: Home-Manager with profiles (consistency, rollback)
- **Shareable configs**: Pure packages (cacheable, versionable)
- **Teams**: Hybrid (devShells for projects, packages for shared configs)

## Key Patterns

### devShells (Recommended for simplicity)
```nix
devShells.default = pkgs.mkShell {
  buildInputs = [ pkgs.fish pkgs.neovim ];
  shellHook = ''
    export XDG_CONFIG_HOME=$PWD/config
    exec fish
  '';
};
```

Usage: `nix develop` or auto-load with direnv

### Home-Manager (For system-wide management)
```nix
programs.fish = {
  enable = true;
  shellAliases = { ... };
};
home.packages = [ pkgs.neovim ];
```

Usage: `home-manager switch --flake .#profile`

### Pure Packages (For shareable configs)
```nix
packages.dotfiles = pkgs.stdenvNoCC.mkDerivation {
  name = "my-dotfiles";
  src = ./configs;
  installPhase = ''
    mkdir -p $out/share/dotfiles
    cp -r * $out/share/dotfiles/
  '';
};
```

Usage: `nix profile install .#dotfiles`
