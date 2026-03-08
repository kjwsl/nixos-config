#!/usr/bin/env bash
# bootstrap.sh — Take a bare system from nothing to a fully configured Nix setup.
#
# Usage:
#   curl -sSfL https://raw.githubusercontent.com/<user>/nixos-config/main/bootstrap.sh | bash
#   # or locally:
#   ./bootstrap.sh
#
# Supports: macOS (nix-darwin), NixOS, and standalone Linux (home-manager).

set -euo pipefail

# ── Colors ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

info()  { echo -e "${BLUE}${BOLD}[INFO]${NC}  $*"; }
ok()    { echo -e "${GREEN}${BOLD}[OK]${NC}    $*"; }
warn()  { echo -e "${YELLOW}${BOLD}[WARN]${NC}  $*"; }
err()   { echo -e "${RED}${BOLD}[ERR]${NC}   $*" >&2; }
die()   { err "$@"; exit 1; }

# ── Config ──────────────────────────────────────────────────────────────────
REPO_URL="https://github.com/kjwdev01/nixos-config.git"  # TODO: update with your actual repo URL
CONFIG_DIR="$HOME/.config/nix-config"

# ── Detect OS ───────────────────────────────────────────────────────────────
detect_os() {
  case "$(uname -s)" in
    Darwin) echo "darwin" ;;
    Linux)
      if [ -f /etc/NIXOS ]; then
        echo "nixos"
      else
        echo "linux"
      fi
      ;;
    *) die "Unsupported operating system: $(uname -s)" ;;
  esac
}

# ── Detect architecture ────────────────────────────────────────────────────
detect_arch() {
  case "$(uname -m)" in
    arm64|aarch64) echo "aarch64" ;;
    x86_64)        echo "x86_64" ;;
    *)             die "Unsupported architecture: $(uname -m)" ;;
  esac
}

# ── Check if Nix is installed ──────────────────────────────────────────────
has_nix() {
  command -v nix &>/dev/null
}

# ── Install Nix via Determinate Systems installer ──────────────────────────
install_nix() {
  if has_nix; then
    ok "Nix is already installed: $(nix --version)"
    return 0
  fi

  info "Installing Nix via Determinate Systems installer..."
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

  # Source nix in current shell
  if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
    # shellcheck source=/dev/null
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  elif [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
    # shellcheck source=/dev/null
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
  fi

  has_nix || die "Nix installation completed but 'nix' not found in PATH. Please restart your shell and re-run this script."
  ok "Nix installed: $(nix --version)"
}

# ── Clone config repo ──────────────────────────────────────────────────────
clone_config() {
  if [ -d "$CONFIG_DIR/.git" ]; then
    info "Config repo already exists at $CONFIG_DIR, pulling latest..."
    git -C "$CONFIG_DIR" pull --rebase || warn "Pull failed, using existing checkout"
  else
    info "Cloning config to $CONFIG_DIR..."
    git clone "$REPO_URL" "$CONFIG_DIR"
  fi
  ok "Config ready at $CONFIG_DIR"
}

# ── Apply configuration ───────────────────────────────────────────────────
apply_darwin() {
  local hostname="${1:-macbook}"
  info "Applying nix-darwin configuration (host: $hostname)..."

  # First run: nix-darwin may not be installed yet
  if ! command -v darwin-rebuild &>/dev/null; then
    info "First run — bootstrapping nix-darwin..."
    nix run nix-darwin -- switch --flake "$CONFIG_DIR#$hostname"
  else
    darwin-rebuild switch --flake "$CONFIG_DIR#$hostname"
  fi

  ok "nix-darwin configuration applied!"
}

apply_nixos() {
  local hostname="${1:-nixos}"
  info "Applying NixOS configuration (host: $hostname)..."
  sudo nixos-rebuild switch --flake "$CONFIG_DIR#$hostname"
  ok "NixOS configuration applied!"
}

apply_home() {
  local profile="${1:-linux}"
  info "Applying standalone home-manager configuration (profile: $profile)..."

  # First run: home-manager may not be installed yet
  if ! command -v home-manager &>/dev/null; then
    info "First run — bootstrapping home-manager..."
    nix run home-manager -- switch --flake "$CONFIG_DIR#$profile" -b backup
  else
    home-manager switch --flake "$CONFIG_DIR#$profile" -b backup
  fi

  ok "Home Manager configuration applied!"
}

# ── Main ───────────────────────────────────────────────────────────────────
main() {
  echo ""
  echo -e "${BOLD}╔══════════════════════════════════════════╗${NC}"
  echo -e "${BOLD}║       Ray's Nix Bootstrap Script         ║${NC}"
  echo -e "${BOLD}╚══════════════════════════════════════════╝${NC}"
  echo ""

  local os arch
  os="$(detect_os)"
  arch="$(detect_arch)"
  info "Detected: os=$os arch=$arch"

  # Step 1: Install Nix
  install_nix

  # Step 2: Clone config
  clone_config

  # Step 3: Apply config based on OS
  case "$os" in
    darwin)
      apply_darwin "macbook"
      ;;
    nixos)
      local hostname
      hostname="$(hostname)"
      # Fall back to "nixos" if hostname doesn't match a known config
      if [ "$hostname" != "nixos" ] && [ "$hostname" != "laptop" ]; then
        warn "Hostname '$hostname' doesn't match a known NixOS config. Using 'nixos'."
        hostname="nixos"
      fi
      apply_nixos "$hostname"
      ;;
    linux)
      apply_home "linux"
      ;;
  esac

  echo ""
  ok "Bootstrap complete! 🎉"
  echo ""
  info "Config location: $CONFIG_DIR"
  info "Next steps:"
  echo "  • Edit config:    cd $CONFIG_DIR && nvim"
  echo "  • Rebuild system: nu $CONFIG_DIR/helper.nu system"
  echo "  • Rebuild home:   nu $CONFIG_DIR/helper.nu home"
  echo "  • Update inputs:  nu $CONFIG_DIR/helper.nu update"
  echo ""
}

main "$@"
