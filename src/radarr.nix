{ config, pkgs, ... }:

let
  fractal = config.fractal;
in {

  environment.systemPackages = with pkgs; [
    wireguard-tools
  ];

  containers.radarr = {
    autoStart = true;
    ephemeral = true;
    privateNetwork = true;
    hostAddress = fractal.radarr.hostIp;
    localAddress = fractal.radarr.localIp;

    bindMounts = {
      "/var/lib/secrets" = {
        hostPath = "/var/lib/secrets";
      };

      "/var/lib/radarr" = {
        hostPath = fractal.radarr.dataPath;
        isReadOnly = false;
      };

      "/mnt/media" = {
        hostPath = fractal.radarr.mediaPath;
        isReadOnly = false;
      };
    };

    config = { config, pkgs, ... }: {
      system.stateVersion = "23.05";
      networking.wireguard.enable = true;
      networking.wg-quick = fractal.mullvad.wg-quick;

      environment.systemPackages = with pkgs; [
        radarr
      ];

      services.radarr = {
        enable = true;
        openFirewall = true;
      };
    };
  };

  networking.hosts = {
    "${fractal.hostIp}" = [ fractal.radarr.domain ];
  };

  services.nginx.virtualHosts.${fractal.radarr.domain} = {
    forceSSL = true;
    enableACME = true;
    locations = {
      "/" = {
        proxyPass = "http://${fractal.radarr.localIp}:7878";
      };
    };
  };
}