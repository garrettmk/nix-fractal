{ config, pkgs, ... }:

let
  fractal = config.fractal;
in {
  # Load the monitoring stack
  environment.systemPackages = with pkgs; [
    prometheus
    prometheus-node-exporter
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
        job_name = fractal.hostName;
        static_configs = [{
          targets = [
            "127.0.0.1:9001"
            "127.0.0.1:9090"
          ];
        }];
      }
    ];
  };
}