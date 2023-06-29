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
      
      localTld = "home";
      hostName = "nix-fractal";
      hostDomain = "${hostName}.${localTld}";
      hostIp = "192.168.122.19";

      step-ca = {
        dataPath = "/mnt/storage/backup/step-ca";
        ip = "192.168.100.21";
        domain = "ca.${hostDomain}";
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
      };

      nextcloud = {
        ip = hostIp;
        domain = "nextcloud.${hostDomain}";
        adminPassword = adminPassword;
        dataPath = "/mnt/storage/backup/nextcloud";
      };
    };
  };
}