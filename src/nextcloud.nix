{ config, pkgs, lib, ... }: 

let
  fractal = config.fractal;
  stateVersion = config.system.stateVersion;
in {
  
  networking.hosts = {
    "${fractal.hostIp}" = [ fractal.nextcloud.domain ];
  };

  services.nginx = {
    virtualHosts = {
      "${fractal.nextcloud.domain}" = {
        forceSSL = true;
        enableACME = true;
      };
    };
  };

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud26;

    hostName = fractal.nextcloud.domain;
    https = true;
    home = fractal.nextcloud.dataPath;
    extraAppsEnable = true;
    
    config = {
      adminpassFile = "${fractal.secretsPath}/nextcloud-admin-password";
      dbtype = "pgsql";
    };

    database = {
      createLocally = true;
    };

    configureRedis = true;
    caching.apcu = false;
  };

  system.activationScripts.script.text = ''
    chown nextcloud:nextcloud ${fractal.secretsPath}/nextcloud-admin-password
    chown nextcloud:nextcloud ${fractal.secretsPath}/nextcloud-db-password
    mkdir -p ${fractal.nextcloud.dataPath};
    chown -R nextcloud:nextcloud ${fractal.nextcloud.dataPath}
  '';
}
