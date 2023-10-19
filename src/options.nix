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
      backupPath = "/mnt/storage/backup";
      mediaPath = "/mnt/storage/media";

      adminUser = {
        name = "garrett";
        fullName = "Garrett Myrick";
      };

      ca = {
        port = 9443;
        domain = "ca-nix-fractal.home";
        dataPath = "${backupPath}/ca";
      };

      prometheus = {
        ip = hostIp;
        port = 9002;
      };

      grafana = {
        port = 9010;
        domain = "grafana.${hostDomain}";
        dataPath = "${backupPath}/grafana";
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
        dataPath = "${backupPath}/nextcloud";
      };

      invidious = {
        port = 9030;
        domain = "invidious.${hostDomain}";
      };

      paperless = {
        port = 9040;
        domain = "paperless.${hostDomain}";
        dataPath = "${backupPath}/paperless";
      };

      gitea = {
        port = 9050;
        domain = "gitea.${hostDomain}";
        dataPath = "${backupPath}/gitea";
      };

      arr = {
        hostIp = "192.168.111.20";
        localIp = "192.168.111.21";

        downloadPath = "${mediaPath}/downloads";
        libraryPath = "${mediaPath}/library";

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
          dataPath = "${backupPath}/deluge";
        };

        prowlarr = {
          domain = "prowlarr.${hostDomain}";
        };

        radarr = {
          domain = "radarr.${hostDomain}";
          dataPath = "${backupPath}/radarr";
        };

        sonarr = {
          domain = "sonarr.${hostDomain}";
          dataPath = "${backupPath}/sonarr";
        };
      };

      jellyfin = {
        domain = "jellyfin.${hostDomain}";
        mediaPath = "${mediaPath}/library";
      };

      homarr = {
        domain = "homarr.${hostDomain}";
        dataPath = "${backupPath}/homarr";
      };

    };
  };
}