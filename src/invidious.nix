{ config, pkgs, ... }: 

let
  fractal = config.fractal;
in {

  environment.systemPackages = with pkgs; [
    invidious
  ];

  services.invidious = {
    enable = true;

    domain = fractal.invidious.domain;
    port = fractal.invidious.port;
    database.createLocally = true;
    settings = {
      external_port = 80;
      popular_enabled = true;
      default_home = "Trending";
      https_only = true;
    };
  };

  networking.hosts = {
    ${fractal.hostIp} = [ fractal.invidious.domain ];
  };

  services.nginx.virtualHosts.${fractal.invidious.domain} = {
    forceSSL = true;
    enableACME = true;
    locations = {
      "/" = {
        proxyPass = "http://localhost:${toString fractal.invidious.port}";
        proxyWebsockets = true;
      };
    };
  };
}