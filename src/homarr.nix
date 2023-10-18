{ config, pkgs, ... }:

let
  fractal = config.fractal;
in {
  systemd.tmpfiles.rules = [
    "d ${fractal.homarr.dataPath}/configs 0777 root root"
    "d ${fractal.homarr.dataPath}/icons 0777 root root"
  ];

  virtualisation.oci-containers.containers.homarr = {
    image = "ghcr.io/ajnart/homarr:latest";
    autoStart = true;
    volumes = [
      "${fractal.homarr.dataPath}/configs:/app/data/configs"
      "${fractal.homarr.dataPath}/icons:/app/public/icons"
    ];
    ports = [
      "7575:7575"
    ];
  };

  networking.hosts = {
    "${fractal.hostIp}" = [
      fractal.homarr.domain
    ];
  };

  services.nginx.virtualHosts = {
    "${fractal.homarr.domain}" = {
      forceSSL = true;
      enableACME = true;
      locations = {
        "/" = {
          proxyPass = "http://localhost:7575";
        };
      };
    };
  };
}