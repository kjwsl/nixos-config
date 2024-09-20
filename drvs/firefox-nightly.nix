{ pkgs }:
pkgs.buildFHSUserEnv {
  name = "firefox-nightly";

  targetPkgs = pkgs: [
    pkgs.coreutils
    pkgs.findutils
    pkgs.curl
    pkgs.glibc
  ];

  runScript = ''
    # Download the latest Firefox Nightly for macOS
        curl -L -o /tmp/firefox-nightly.dmg https://download.mozilla.org/?product=firefox-nightly-latest-ssl&os=osx&lang=en-US

        # Mount the dmg file
        hdiutil attach -mountpoint /Volumes/FirefoxNightly /tmp/firefox-nightly.dmg

        # Copy the app to the Applications directory
        mkdir -p $HOME/Applications
        cp -r /Volumes/FirefoxNightly/Firefox\ Nightly.app $HOME/Applications

        # Unmount the dmg file
        hdiutil detach /Volumes/FirefoxNightly
  '';
}
