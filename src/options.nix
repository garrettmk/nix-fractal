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

      gitea = {
        port = 9050;
        domain = "gitea.nix-fractal.home";
        dataPath = "/mnt/storage/backup/gitea";
      };

      arr = {
        hostIp = "192.168.111.20";
        localIp = "192.168.111.21";

        downloadPath = "/mnt/storage/media/downloads";
        libraryPath = "/mnt/storage/media/library";

        mullvad = {
          wg-quick = {
            interfaces = {
              wg0 = {
                address = [ "10.66.54.175/32" "fc00:bbbb:bbbb:bb01::4:301e/128" ];
                dns = [ "100.64.0.31" ];
                privateKeyFile = "${secretsPath}/mullvad-private-key";

                peers = [
                  {
                    publicKey = "5FZW+fNA2iVBSY99HFl+KjGc9AFVNE+UFAedLNhu8lc=";
                    allowedIPs = [ "0.0.0.0/0" "::0/0" ];
                    endpoint = "178.249.209.162:51820";
                    persistentKeepalive = 25;
                  }
                ];
              };
            };
          };
        };

        deluge = {
          domain = "deluge.${hostDomain}";
          dataPath = "/mnt/storage/backup/deluge";
        };

        prowlarr = {
          domain = "prowlarr.${hostDomain}";
        };

        radarr = {
          domain = "radarr.${hostDomain}";
          dataPath = "/mnt/storage/backup/radarr";
        };

        sonarr = {
          domain = "sonarr.${hostDomain}";
          dataPath = "/mnt/storage/backup/sonarr";
        };
      };

      jellyfin = {
        domain = "jellyfin.${hostDomain}";
        mediaPath = "/mnt/storage/media/library";
      };

      homarr = {
        domain = "homarr.${hostDomain}";
        dataPath = "/mnt/storage/backup/homarr";
      };
      
    };
  };
}