self: super: {
  # Override Node.js to use a specific version
  nodejs = super.nodejs_20;

  # Add custom Python packages
  python3 = super.python3.override {
    packageOverrides = python-self: python-super: {
      # Add custom Python packages
      my-custom-package = python-super.buildPythonPackage {
        pname = "my-custom-package";
        version = "1.0.0";
        src = ./sources/my-custom-package;
        propagatedBuildInputs = with python-super; [
          requests
          click
        ];
      };
    };
  };

  # Override Rust toolchain
  rustc = super.rustc.override {
    extensions = [ "rust-src" "rust-analyzer" ];
  };

  # Add custom development tools
  dev-tools = super.symlinkJoin {
    name = "dev-tools";
    paths = with super; [
      # Development utilities
      git
      lazygit
      gh
      delta
      
      # Code formatters
      nixpkgs-fmt
      black
      rustfmt
      
      # Linters
      shellcheck
      clippy
      pylint
    ];
  };
} 