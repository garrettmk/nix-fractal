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
      dataPath = "/mnt/storage/backup";

      adminUser = {
        name = "garrett";
        fullName = "Garrett Myrick";
      };

      ca = {
        port = 9443;
        domain = "ca-nix-fractal.home";
        dataPath = "/mnt/storage/backup/ca";
      };

      prometheus = {
        ip = hostIp;
        port = 9002;
      };

      grafana = {
        port = 9010;
        domain = "grafana.${hostDomain}";
        dataPath = "/mnt/storage/backup/grafana";
      };

      pihole = {
        ip = "10.88.0.53";
        domain = "pihole.${hostDomain}";
        adminPassword = adminPassword;
        fallbackDNS = "192.168.122.1";
      };

      nextcloud = {
        port =  9020;
        domain = "nextcloud.${hostDomain}";
        dataPath = "/mnt/storage/backup/nextcloud";
      };

      invidious = {
        port = 9030;
        domain = "invidious.nix-fractal.home";
      };

      paperless = {
        port = 9040;
        domain = "paperless.nix-fractal.home";
        dataPath = "/mnt/storage/backup/paperless";
      };
    };
  };
}