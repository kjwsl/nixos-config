{ pkgs ? import <nixpkgs> {} }:

let
  # Common packages for all environments
  common-packages = with pkgs; [
    # Version control
    git
    git-lfs
    gh

    # Shell tools
    fish
    zoxide
    fzf
    bat
    eza
    ripgrep

    # Development tools
    neovim
    tmux
    lazygit
    delta
  ];

  # Python development environment
  python-env = with pkgs; [
    python3
    python3Packages.pip
    python3Packages.virtualenv
    python3Packages.pytest
    python3Packages.black
    python3Packages.flake8
    python3Packages.mypy
    python3Packages.ipython
    python3Packages.jupyter
    python3Packages.poetry
  ];

  # Node.js development environment
  nodejs-env = with pkgs; [
    nodejs_20
    yarn
    nodePackages.typescript
    nodePackages.typescript-language-server
    nodePackages.prettier
    nodePackages.eslint
    nodePackages.npm-check-updates
  ];

  # Rust development environment
  rust-env = with pkgs; [
    rustc
    cargo
    rustfmt
    clippy
    rust-analyzer
    cargo-watch
    cargo-edit
    cargo-expand
    cargo-udeps
  ];

  # Web development environment
  web-env = with pkgs; [
    nodejs_20
    yarn
    nodePackages.typescript
    nodePackages.prettier
    nodePackages.eslint
    chromium
    firefox
    wget
    curl
  ];

  # System development environment
  system-env = with pkgs; [
    gcc
    gdb
    valgrind
    strace
    ltrace
    perf
    systemd
    pkg-config
  ];

  # Database development environment
  db-env = with pkgs; [
    postgresql
    mysql
    sqlite
    redis
    mongodb
    pgcli
    mycli
  ];

  # Machine Learning environment
  ml-env = with pkgs; [
    python3
    python3Packages.numpy
    python3Packages.pandas
    python3Packages.scipy
    python3Packages.scikit-learn
    python3Packages.tensorflow
    python3Packages.torch
    python3Packages.jupyter
    python3Packages.matplotlib
    python3Packages.seaborn
  ];

  # DevOps environment
  devops-env = with pkgs; [
    docker
    docker-compose
    kubernetes
    kubectl
    helm
    terraform
    ansible
    awscli2
    azure-cli
    google-cloud-sdk
  ];

  # Function to create a development shell
  mkDevShell = packages: pkgs.mkShell {
    buildInputs = common-packages ++ packages;
    shellHook = ''
      export EDITOR=nvim
      export SHELL=fish
      exec fish
    '';
  };

in {
  # Export different development environments
  python = mkDevShell python-env;
  nodejs = mkDevShell nodejs-env;
  rust = mkDevShell rust-env;
  web = mkDevShell web-env;
  system = mkDevShell system-env;
  database = mkDevShell db-env;
  ml = mkDevShell ml-env;
  devops = mkDevShell devops-env;
} 