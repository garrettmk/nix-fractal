{ config, pkgs, ... }:

let
  fractal = config.fractal;
in {

  environment.systemPackages = with pkgs; [
    paperless-ngx
  ];

  environment.noXlibs = true;

  services.paperless = {
    enable = true;
    port = fractal.paperless.port;
    dataDir = "${fractal.paperless.dataPath}/data";
    passwordFile = "${fractal.secretsPath}/paperless-password";
  };

  services.nginx.virtualHosts.${fractal.paperless.domain} = {
    locations = {
      "/" = {
        proxyPass = "http://localhost:${toString fractal.paperless.port}";
        proxyWebsockets = true;
      };
    };
  };
}