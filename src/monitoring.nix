{ config, pkgs, ... }:

{
  # Load the monitoring stack
  environment.systemPackages = with pkgs; [
    prometheus
    prometheus-node-exporter
    grafana
  ];
  
  # Allow access to grafana from outside
  networking.firewall.allowedTCPPorts = [
    # 9001
    # 9002
    9003
    # 9090
  ];

  # Set up node_exporter and prometheus
  services.prometheus = {
    enable = true;
    port = 9002;
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = 9001;
      };
    };

    scrapeConfigs = [
      {
        job_name = "nix-fractal";
        static_configs = [{
          targets = [
            "127.0.0.1:9001"
            "127.0.0.1:9090"
          ];
        }];
      }
    ];
  };

  # Set up grafana
  services.grafana = {
    enable = true;
    settings = {
      server.http_port = 9003;
    };
    provision = {
      enable = true;
      datasources = {
        settings = {
          datasources = [
            {
              name = "Prometheus";
              type = "prometheus";
              url = "http://localhost:9002";
              isDefault = true;
            }
          ];
        };
      };
      dashboards = {
        settings = {
          providers = [
            {
              name = "Nix-Fractal Dashboard";
              options.path = "/etc/grafana/dashboards";
            }
          ];
        };
      };
    };
  };

  environment.etc = {
    "grafana/dashboards/1-node-exporter-0-16-for-prometheus-monitoring-display-board_rev1.json" = {
      source = ./grafana/dashboards/1-node-exporter-0-16-for-prometheus-monitoring-display-board_rev1.json;
      user = "grafana";
      group = "grafana";
    };
  };
}