{ config, pkgs, ... }:

let
  fractal = config.fractal;
in {
  environment.systemPackages = with pkgs; [
    jellyfin
  ];

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  networking.hosts = {
    ${fractal.hostIp} = [ fractal.jellyfin.domain ];
  };

  services.nginx.virtualHosts.${fractal.jellyfin.domain} = {
    forceSSL = true;
    enableACME = true;
    locations = {
      "/" = {
        proxyPass = "http://localhost:8096";
        proxyWebsockets = true;
      };
    };
  };
}