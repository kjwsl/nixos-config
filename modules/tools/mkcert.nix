# Contributes to flake.modules.homeManager.base.
{...}: {
  flake.modules.homeManager.base = {
    config,
    pkgs,
    lib,
    ...
  }: let
    certDir = "${config.home.homeDirectory}/.certs";
    certFile = "${certDir}/zellij.pem";
    keyFile = "${certDir}/zellij-key.pem";
    mkcertPath = "${lib.getExe pkgs.mkcert}";
  in {
    # Activation script to generate certificates if they don't exist
    home.activation.generateZellijCerts = lib.hm.dag.entryAfter ["writeBoundary"] ''
      # Create the certificate directory if it doesn't exist
      run mkdir -p ${certDir}

      # Check if the certificate files already exist to avoid re-running mkcert unnecessarily
      if [ ! -f ${certFile} ] || [ ! -f ${keyFile} ]; then
        # Strip .local if it exists to avoid double suffixes
        MY_HOST=$(uname -n | sed 's/\.local$//')
        run ${mkcertPath} \
          -cert-file ${certFile} \
          -key-file ${keyFile} \
          localhost 127.0.0.1 0.0.0.0 "$MY_HOST" "$MY_HOST.local"
      else
        run echo "Zellij certificates already exist in ${certDir}"
      fi
    '';
  };
}
