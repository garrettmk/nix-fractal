{ config, pkgs, lib, ... }: 

let
  fractal = config.fractal;
  stateVersion = config.system.stateVersion;
in {

  systemd.tmpfiles.rules = [
    "d ${fractal.nextcloud.dataPath}/nextcloud"
    "d ${fractal.nextcloud.dataPath}/postgresql"
  ];

  containers.nextcloud = {
    ephemeral = true;
    autoStart = true;
    privateNetwork = true;
    hostAddress = fractal.nextcloud.ip;
    localAddress = "10.99.0.11";

    bindMounts = {
      "/var/lib/nextcloud" = {
        hostPath = "${fractal.nextcloud.dataPath}/nextcloud";
        isReadOnly = false;
      };

      "/var/lib/postgresql" = {
        hostPath = "${fractal.nextcloud.dataPath}/postgresql";
        isReadOnly = false;
      };
    };

    config = { config, pkgs, ... }: {
      system.stateVersion = stateVersion;
      environment.etc."resolv.conf".text = "nameserver ${fractal.hostIp}";
      
      networking.firewall = {
        enable = true;
        allowedTCPPorts = [ 80 443 ];
      };

      services.nextcloud = {
        enable = true;
        package = pkgs.nextcloud26;
        hostName = fractal.nextcloud.domain;
        configureRedis = true;
        caching.apcu = false;
        config.adminpassFile = "${fractal.secretsPath}/nextcloud-admin-password";
        config.dbtype = "pgsql";
        database.createLocally = true;
        extraOptions = {
          mail_smtpmode = "sendmail";
          mail_sendmailmode = "pipe";
        };
      };
    };
  };

  networking.hosts = {
    "${fractal.hostIp}" = [ fractal.nextcloud.domain ];
  };

  # nginx/acme
  services.nginx = {
    enable = true;
    virtualHosts = {
      "${fractal.nextcloud.domain}" = {
        forceSSL = true;
        enableACME = true;
        locations = {
          "/" = {
            recommendedProxySettings = true;
            proxyPass = "http://${fractal.nextcloud.ip}";
            proxyWebsockets = true;
          };
        };
      };
    };
  };
}