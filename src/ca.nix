{ config, pkgs, ... }:

let
  fractal = config.fractal;
  stateVersion = config.system.stateVersion;
in {

  # Add the CA to hosts
  networking.hosts = {
    "${fractal.ca.ip}" = [ fractal.ca.domain ];
  };

  # networking.firewall = {
  #   allowedTCPPorts = [ 9443 ];
  # };

  # services.nginx.virtualHosts = {
  #   "${fractal.ca.domain}" = {
  #     locations = {
  #       "/" = {
  #         recommendedProxySettings = true;
  #         proxyPass = "https://${fractal.ca.ip}:${toString fractal.ca.port}";
  #       };
  #     };
  #   };
  # };

  # Install necessary packages
  environment.systemPackages = with pkgs; [
    step-ca
    step-cli
  ];

  # Run the CA
  systemd.units."step-ca.service" = let
    initScript = pkgs.writeScriptBin "step-ca-init" ''
      #!/run/current-system/sw/bin/bash
      PATH=/run/current-system/sw/bin
      STEPPATH=/root/.step

      if [ -d "$STEPPATH" ]; then
        echo "step-ca already initialized, exiting"
        exit 0
      fi

      mkdir -p /etc/pki/keys
      echo 'h1|.VI.xP=MUi!!@}e!6M_F#y[p>cW}{' > /etc/pki/keys/step-ca-password
      echo 'h1|.VI.xP=MUi!!@}e!6M_F#y[p>abc2' > /etc/pki/keys/step-ca-provisioner-password
      
      step ca init \
        --deployment-type=standalone \
        --name=${fractal.hostName}-ca \
        --dns=${fractal.ca.domain} \
        --address=${fractal.ca.ip}:${toString fractal.ca.port} \
        --provisioner=admin@${fractal.hostDomain} \
        --acme \
        --password-file=/etc/pki/keys/step-ca-password \
        --provisioner-password-file=/etc/pki/keys/step-ca-provisioner-password
    '';

    serviceScript = pkgs.writeScriptBin "step-ca-run" ''
      #!/run/current-system/sw/bin/bash
      PATH=/run/current-system/sw/bin
      STEPPATH=/root/.step

      step-ca --password-file=/etc/pki/keys/step-ca-password
    '';
  in {
    enable = true;
    wantedBy = [ "multi-user.target" "acme-fixperms.service" ];
    text = ''
      [Unit]
      Description=Run the CA

      [Service]
      Type=simple
      ExecStartPre=${initScript}/bin/step-ca-init
      ExecStart=${serviceScript}/bin/step-ca-run
    '';
  };
}


# PW: h1|.VI.xP=MUi!!@}e!6M_F#y[p>cW}{