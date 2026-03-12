# DevShell for running the `setup.nu` script
{ ... }: {
  perSystem = { pkgs, ... }: {
    devShells.default = pkgs.mkShell {
      buildInputs = with pkgs; [ nushell nh ];
    };
  };
}
