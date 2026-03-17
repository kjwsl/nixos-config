# nix-ld configuration for running unpatched binaries.
{pkgs, ...}: {
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    fuse3
    icu
    nss
    openssl
    curl
    expat
    # Add more libraries as needed
  ];
}
