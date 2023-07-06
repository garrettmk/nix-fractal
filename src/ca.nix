{ config, pkgs, ... }:

let
  fractal = config.fractal;
  stateVersion = config.system.stateVersion;
  stepPath = "${fractal.ca.dataPath}/step-ca";
in {

  # Add our CA root certificate to the trust store
  security.pki.certificateFiles = [
    ./pki/roots.pem
  ];

  # Allow outside access
  networking.firewall.allowedTCPPorts = [ fractal.ca.port ];

  # Add the CA to hosts
  networking.hosts = {
    "${fractal.hostIp}" = [ fractal.ca.domain ];
  };

  # Install necessary packages
  environment.systemPackages = with pkgs; [
    step-ca
    step-cli
    openssl
  ];

  # Didn't work using the variable defined above,
  # no idea why
  environment.variables = {
    STEPPATH = "${fractal.ca.dataPath}/step-ca";
  };

  # Run the CA
  systemd.units."step-ca.service" = let
    initScript = pkgs.writeScriptBin "step-ca-init" ''
      #!/run/current-system/sw/bin/bash

      if [ -d "$STEPPATH" ]; then
        echo "step-ca already initialized, exiting"
        exit 0
      fi
      
      step ca init \
        --deployment-type=standalone \
        --name=${fractal.hostName}-ca \
        --dns=${fractal.ca.domain} \
        --address=${fractal.hostIp}:${toString fractal.ca.port} \
        --provisioner=admin@${fractal.hostDomain} \
        --acme \
        --password-file=${fractal.secretsPath}/step-ca-password \
        --provisioner-password-file=${fractal.secretsPath}/step-ca-provisioner-password
    '';

    serviceScript = pkgs.writeScriptBin "step-ca-run" ''
      #!/run/current-system/sw/bin/bash

      step-ca --password-file=${fractal.secretsPath}/step-ca-password
    '';
  in {
    enable = true;
    wantedBy = [ "multi-user.target" "acme-fixperms.service" ];
    text = ''
      [Unit]
      Description=Run the CA

      [Service]
      Type=simple
      Environment="PATH=/run/current-system/sw/bin"
      Environment="STEPPATH=${stepPath}"
      ExecStartPre=${initScript}/bin/step-ca-init
      ExecStart=${serviceScript}/bin/step-ca-run
    '';
  };
}