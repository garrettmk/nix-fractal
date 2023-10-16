{ config, pkgs, ... }:

let
  fractal = config.fractal;
in {

  containers.deluge = {
    autoStart = true;
    ephemeral = true;
    privateNetwork = true;
    hostAddress = fractal.deluge.hostIp;
    localAddress = fractal.deluge.localIp;

    bindMounts = {
      "/var/lib/secrets" = {
        hostPath = "/var/lib/secrets";
      };

      "/var/lib/deluge" = {
        hostPath = fractal.deluge.dataPath;
        isReadOnly = false;
      };
    };

    config = { config, pkgs, ... }: {
      system.stateVersion = "23.05";
      networking.wireguard.enable = true;
      networking.wg-quick = fractal.mullvad.wg-quick;

      environment.systemPackages = with pkgs; [
        deluged
      ];

      services.deluge = {
        enable = true;
        dataDir = fractal.deluge.dataPath;
        
        web = {
          enable = true;
          port = 8112;
          openFirewall = true;
        };
      };
    };
  };

  networking.hosts = {
    "${fractal.hostIp}" = [ fractal.deluge.domain ];
  };

  services.nginx.virtualHosts.${fractal.deluge.domain} = {
    forceSSL = true;
    enableACME = true;
    locations = {
      "/" = {
        proxyPass = "http://${fractal.deluge.localIp}:8112";
      };
    };
  };
}