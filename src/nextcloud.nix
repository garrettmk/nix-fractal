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
    hostAddress = "192.168.100.10";
    localAddress = "192.168.100.11";
    hostAddress6 = "fc00::1";
    localAddress6 = "fc00::2";

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

    # Is this even doing anything?
    extraFlags = [
      "--private-users=yes"
      # "--bind=${fractal.nextcloud.dataPath}/nextcloud:/var/lib/nextcloud:rbind,rootidmap"
      # "--bind=${fractal.nextcloud.dataPath}/postgresql:/var/lib/postgresql:rbind,rootidmap"
    ];

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
        hostName = "nextcloud.${fractal.hostDomain}";
        configureRedis = true;
        caching.apcu = false;
        config.adminpassFile = "${pkgs.writeText "adminpass" fractal.nextcloud.adminPassword}";
        config.dbtype = "pgsql";
        database.createLocally = true;
        extraOptions = {
          mail_smtpmode = "sendmail";
          mail_sendmailmode = "pipe";
        };
      };
    };
  };

  # nginx/acme
  services.nginx = {
    enable = true;
    virtualHosts = {
      "nextcloud.${fractal.hostDomain}" = {
        forceSSL = true;
        enableACME = true;
        locations = {
          "/" = {
            recommendedProxySettings = true;
            proxyPass = "http://192.168.100.11/";
            proxyWebsockets = true;
          };
        };
      };
    };
  };
}