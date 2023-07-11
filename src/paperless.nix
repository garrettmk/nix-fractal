{ config, pkgs, ... }:

let
  fractal = config.fractal;
in {

  environment.systemPackages = with pkgs; [
    paperless-ngx
  ];

  environment.noXlibs = false;

  services.paperless = {
    enable = true;
    port = fractal.paperless.port;
    dataDir = "${fractal.paperless.dataPath}/data";
    passwordFile = "${fractal.secretsPath}/paperless-password";
  };

  networking.hosts = {
    "${fractal.hostIp}" = [ fractal.paperless.domain ];
  };

  services.nginx.virtualHosts.${fractal.paperless.domain} = {
    forceSSL = true;
    enableACME = true;
    locations = {
      "/" = {
        proxyPass = "http://localhost:${toString fractal.paperless.port}";
        proxyWebsockets = true;
      };
    };
  };
}