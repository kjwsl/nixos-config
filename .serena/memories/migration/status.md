# Migration Status: Chezmoi → Nix-First

## Current State: Phase 2-3 Complete ✅

### Completed
- ✅ Audit: 799 chezmoi files categorized
- ✅ Modular structure: `home/programs/`, `home/platform/`
- ✅ Shells migrated: fish, nushell, bash, zsh → `home/programs/shells.nix`
- ✅ VCS migrated: git, jujutsu, lazygit, gh → `home/programs/git.nix`
- ✅ Mutable symlinks: 10 configs → `home/dotfiles.nix`
- ✅ Build validated: Successful, no errors

### Pending
- Phase 4: CLI tools (btop, yazi, starship, fastfetch)
- Phase 5: Chezmoi cleanup/elimination

### Architecture
```
home/programs/shells.nix  # Shells + session vars
home/programs/git.nix      # VCS tools + delta
home/dotfiles.nix          # Mutable symlinks (mkOutOfStoreSymlink)
dotfiles/{nvim,wezterm,ghostty,alacritty,kitty,tmux,zellij,aerospace,karabiner,sketchybar}/
```

### Next: Activate with `home-manager switch --flake .#ray-darwin`
