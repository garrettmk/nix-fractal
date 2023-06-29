{ config, pkgs, ... }:

let
  fractal = config.fractal;
in {
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
    ];
  };

  # Configure systemd-resolved to use the pihole container for name resolution
  services.resolved = {
    enable = true;
    domains = ["~."];
    
    # Use only the Pihole container for DNS resolution
    # Tell the stub listener to allow DNS queries from the local network
    extraConfig = ''
      [Resolve]
      DNS=${fractal.pihole.ip}
      DNSStubListener=yes
      DNSStubListenerExtra=${fractal.hostIp}
    '';
  };

  # Proxy a subdomain to the container
  services.nginx = {
    enable = true;
    virtualHosts = {
      "pihole.${fractal.hostDomain}" = {
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