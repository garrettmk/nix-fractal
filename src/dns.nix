{ config, pkgs, ... }:

let
  fractal = config.fractal;
in {
  # Add ourselves and other known hosts to the hosts
  # file so we can refer to them by name
  networking.hosts = {
    "192.168.0.11" = ["caladan.home"];
    "${fractal.hostIp}" = [
      "${fractal.hostDomain}"
      "${fractal.pihole.domain}"
    ];
  };

  # Run pihole in a podman container
  virtualisation.oci-containers.containers.pihole = {
    image = "docker.io/pihole/pihole";
    autoStart = true;
    volumes = ["pihole-data:/etc/pihole"];
    environment = {
      WEBPASSWORD = fractal.pihole.adminPassword;
      TZ = fractal.timeZone;
    };
    extraOptions = [
      "--cap-add=NET_ADMIN"
      "--ip=${fractal.pihole.ip}"
      "--dns=127.0.0.1"
      "--dns=1.1.1.1"
    ];
  };

  # Configure systemd-resolved to use the pihole container for name resolution
  services.resolved = {
    enable = true;
    domains = ["~."];
    
    # Use the Pihole container for DNS resolution
    # Tell the stub listener to allow DNS queries from the local network
    # If pihole is unavailable, the fallback servers are used
    # To *only* use pihole for DNS resolution, add the line:
    #
    # FallbackDNS=
    extraConfig = ''
      [Resolve]
      DNS=${fractal.pihole.ip}
      DNSStubListener=yes
      DNSStubListenerExtra=${fractal.hostIp}
    '';
  };

  # Proxy a subdomain to the container
  services.nginx = {
    virtualHosts = {
      "${fractal.pihole.domain}" = {
        # forceSSL = true;
        # enableACME = true;
        locations = {
          # Redirect root to the login page
          "= /" = {
            extraConfig = ''
              rewrite ^ /admin/login.php permanent;
            '';
          };

          # Pass everything to the container
          "/" = {
            recommendedProxySettings = true;
            proxyPass = "http://${fractal.pihole.ip}/";
            proxyWebsockets = true;
          };
        };
      };
    };
  };
}