# Home Manager Recent Improvements

## New Modules

### modules/privacy.nix
Privacy tools with opt-in design:
- i2p network (HTTP/SOCKS proxies)
- v2ray with GUI (v2raya)
- Disabled by default

### modules/tools.nix Additions
Network: bandwhich, procs, bottom
Text: sd, choose, tealdeer, navi
Dev: tokei, onefetch, direnv
Files: xcp, ouch
HTTP: xh, curlie
Other: silicon, zenith

## Starship Configuration

starship-modern.toml features:
- Nord theme, two-line prompt
- Jujutsu VCS support (custom modules)
- 20+ languages, cloud platforms
- Performance optimized

## Profile Organization

```
profiles/
├── base.nix         # Minimal essentials
├── development.nix  # Full dev + privacy module
├── minimal.nix      # Bare minimum
├── personal.nix     # Personal machine
└── work.nix         # Work machine
```

## Best Practices

1. Use programs.* modules when available
2. Opt-in services by default
3. One module per concern
4. Force overwrite: `xdg.configFile."path".force = true`
5. --impure for environment variable access
