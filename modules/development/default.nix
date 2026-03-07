# Development tools module.
# Installs system-level development utilities: compilers, build tools, runtimes, and helpers.
{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # Version control
    git

    # Editors
    neovim

    # C/C++ toolchain
    gcc
    clang
    gnumake
    cmake
    ninja

    # Scripting / runtimes
    nodejs
    python3
    go

    # Rust managed via rustup (avoid collision with system rustc)
    rustup

    # Nix tooling
    nil # Nix LSP
    alejandra # Nix formatter
    nix-tree

    # General dev helpers
    jq
    curl
    openssl
    pkg-config
  ];

  # Allow dynamically-linked pre-built binaries (e.g. downloaded sdks, electron apps)
  programs.nix-ld.enable = true;
}
