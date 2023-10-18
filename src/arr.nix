{ config, pkgs, ... }:

let
  fractal = config.fractal;
in {

  systemd.tmpfiles.rules = [
    "d ${fractal.arr.deluge.dataPath} 0777 root root"
    "d ${fractal.arr.radarr.dataPath} 0777 root root"
    "d ${fractal.arr.sonarr.dataPath} 0777 root root"
  ];

  containers.arr = {
    autoStart = true;
    ephemeral = true;
    privateNetwork = true;
    hostAddress = fractal.arr.hostIp;
    localAddress = fractal.arr.localIp;

    bindMounts = {
      "${fractal.secretsPath}" = {
        hostPath = "${fractal.secretsPath}";
      };

      "${fractal.arr.downloadPath}" = {
        hostPath = fractal.arr.downloadPath;
        isReadOnly = false;
      };

      "${fractal.arr.libraryPath}" = {
        hostPath = fractal.arr.libraryPath;
        isReadOnly = false;
      };

      "/var/lib/deluge" = {
        hostPath = fractal.arr.deluge.dataPath;
        isReadOnly = false;
      };

      "/var/lib/radarr" = {
        hostPath = fractal.arr.radarr.dataPath;
        isReadOnly = false;
      };

      "/var/lib/sonarr" = {
        hostPath = fractal.arr.sonarr.dataPath;
        isReadOnly = false;
      };
    };

    config = { config, pkgs, ... }: {
      system.stateVersion = "23.05";
      networking.wireguard.enable = true;
      networking.wg-quick = fractal.arr.mullvad.wg-quick;

      environment.systemPackages = with pkgs; [
        deluged
        prowlarr
        radarr
        sonarr
      ];

      services = {
        deluge = {
          enable = true;
          
          web = {
            enable = true;
            openFirewall = true;
          };
        };

        prowlarr = {
          enable = true;
          openFirewall = true;
        };

        radarr = {
          enable = true;
          openFirewall = true;
        };

        sonarr = {
          enable = true;
          openFirewall = true;
        };
      };
    };
  };

  networking.hosts = {
    "${fractal.hostIp}" = [
      fractal.arr.deluge.domain
      fractal.arr.prowlarr.domain
      fractal.arr.radarr.domain
      fractal.arr.sonarr.domain
    ];
  };

  services.nginx.virtualHosts = {
    "${fractal.arr.deluge.domain}" = {
      forceSSL = true;
      enableACME = true;
      locations = {
        "/" = {
          proxyPass = "http://${fractal.arr.localIp}:8112";
        };
      };
    };

    "${fractal.arr.prowlarr.domain}" = {
      forceSSL = true;
      enableACME = true;
      locations = {
        "/" = {
          proxyPass = "http://${fractal.arr.localIp}:9696";
        };
      };
    };

    "${fractal.arr.radarr.domain}" = {
      forceSSL = true;
      enableACME = true;
      locations = {
        "/" = {
          proxyPass = "http://${fractal.arr.localIp}:7878";
        };
      };
    };

    "${fractal.arr.sonarr.domain}" = {
      forceSSL = true;
      enableACME = true;
      locations = {
        "/" = {
          proxyPass = "http://${fractal.arr.localIp}:8989";
        };
      };
    };
  };
}