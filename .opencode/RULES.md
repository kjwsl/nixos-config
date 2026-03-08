# NixOS Config — OpenCode Rules

## Repository Structure

- `flake.nix` — Minimal entry point. Uses `import-tree` to load all modules under `./modules/`
- `modules/tools/` — Home Manager tool configurations (opencode, editors, CLI tools)
- `modules/home.nix` — Base home-manager config shared across hosts
- `modules/hosts/` — Per-host NixOS/nix-darwin system configurations
- `modules/theming/` — Catppuccin and theme-related config
- `modules/shell/` — Shell (nushell, zsh, aliases) configuration

## Nix Conventions

- This is a **flake-parts** project — modules export via `flake.modules.homeManager.base` or `flake.modules.nixos`
- All `.nix` files under `modules/` are auto-imported via `import-tree` — no manual imports needed
- Use `nix fmt` to format Nix files (alejandra formatter)
- Run `nix flake check` before applying any changes
- On macOS: rebuild with `darwin-rebuild switch --flake .#<hostname>`

## What to Follow

- Match the attribute-set style used in existing modules (no semicolons on last attr, consistent indentation)
- Home Manager options go in `programs.opencode`, `programs.neovim`, etc. — not raw file writes
- System packages go in `environment.systemPackages`, user packages in `home.packages`
- Keep each module focused on one tool or concern — don't bundle unrelated config

## What NOT to Do

- Never edit files in `/nix/store/` — they are read-only by design
- Never write directly to `~/.config/opencode/opencode.json` — it's a Home Manager symlink
- Don't add `inputs.nixpkgs.follows` overrides unless specifically needed
- Don't commit `result/` symlinks or `.direnv/` directories
