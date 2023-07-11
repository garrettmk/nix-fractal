{ config, pkgs, ... }:

let
  fractal = config.fractal;
in {

  environment.systemPackages = with pkgs; [
    gitea
  ];

  services.gitea = {
    enable = true;

    stateDir = fractal.gitea.dataPath;

    settings.server = {
      PROTOCOL = "http";
      HTTP_ADDR = "127.0.0.1";
      HTTP_PORT = fractal.gitea.port;
      DOMAIN = fractal.gitea.domain;
    };

    database.createDatabase = true;
  };

  networking.hosts = {
    ${fractal.hostIp} = [ fractal.gitea.domain ];
  };

  services.nginx.virtualHosts.${fractal.gitea.domain} = {
    forceSSL = true;
    enableACME = true;
    locations = {
      "/" = {
        proxyPass = "http://localhost:${toString fractal.gitea.port}";
      };
    };
  };
}