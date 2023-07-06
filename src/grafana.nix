{ config, pkgs, ... }:

let
  fractal = config.fractal;
  stateVersion = config.system.stateVersion;
in {

  environment.systemPackages = with pkgs; [
    grafana
  ];

  services.grafana = {
    enable = true;

    dataDir = fractal.grafana.dataPath;

    settings = {
      server = {
        domain = fractal.grafana.domain;
        http_port = fractal.grafana.port;
      };
    };

    provision = {
      enable = true;
      datasources = {
        settings = {
          datasources = [
            {
              name = "Prometheus";
              type = "prometheus";
              url = "http://${fractal.prometheus.ip}:${toString fractal.prometheus.port}";
              isDefault = true;
            }
          ];
        };
      };
      dashboards = {
        settings = {
          providers = [
            {
              name = "Nix-Fractal Dashboards";
              options.path = "/var/lib/grafana";
            }
          ];
        };
      };
    };
  };


  networking.hosts = {
    "${fractal.hostIp}" = [ "${fractal.grafana.domain}" ];
  };

  services.nginx.virtualHosts = {
    "${fractal.grafana.domain}" = {
      forceSSL = true;
      enableACME = true;
      locations = {
        "/" = {
          proxyPass = "http://localhost:${toString fractal.grafana.port}";
          proxyWebsockets = true;
        };
      };
    };
  };
}