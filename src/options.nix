{ lib, ... }:

with lib;
with types;
let
  adminPassword = "admin";
in {
  options = {
    fractal = mkOption {
      type = attrs;
      description = "Some custom attributes";
    };
  };

  config = {
    fractal = rec {
      timeZone = "America/Los_Angeles";
      locale = "en_US.UTF-8";
      
      hostTLD = "home";
      hostName = "nix-fractal";
      hostDomain = "${hostName}.${hostTLD}";
      hostIp = "192.168.122.19";

      secretsPath = "/var/lib/secrets";

      adminUser = {
        name = "garrett";
        fullName = "Garrett Myrick";
      };

      ca = {
        dataPath = "/mnt/storage/backup/step-ca";
        ip = hostIp;
        port = 9443;
        # domain = "ca.${hostDomain}";
        domain = "ca-nix-fractal.home";
      };

      grafana = {
        ip = hostIp;
        domain = "grafana.${hostDomain}";
        adminPassword = adminPassword;
      };

      pihole = {
        ip = "10.88.0.53";
        domain = "pihole.${hostDomain}";
        adminPassword = adminPassword;
        fallbackDNS = "192.168.122.1";
      };

      # nextcloud = {
      #   ip = "10.99.0.10";
      #   domain = "nextcloud.${hostDomain}";
      #   dataPath = "/mnt/storage/backup/nextcloud";
      # };
    };
  };
}