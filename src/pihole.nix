{ config, pkgs, ... }:

let
  fractal = config.fractal;
in {
  # Add ourselves and other known hosts to the hosts
  # file so we can refer to them by name
  networking.hosts = {
    ${fractal.hostIp} = [ fractal.pihole.domain ];
  };

  # Allow DNS requests from the network
  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
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
    # If pihole is unavailable, the cloudflare servers are used
    extraConfig = ''
      [Resolve]
      DNS=${fractal.pihole.ip} 1.1.1.1 1.0.0.1
      DNSStubListener=yes
      DNSStubListenerExtra=${fractal.hostIp}
    '';
  };

  # On first install, we won't have the pihole image. So the pihole IP won't
  # respond, and systemd-resolved will move on to the next DNS server. Once
  # pihole starts, we can restart systemd-resolved and it will use the pihole
  # DNS address again.
  systemd.units."pihole-restart-resolved" = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    text = ''
      [Unit]
      Description=Restart systemd-resolved when pihole comes online
      After=podman-pihole.service

      [Service]
      Type=oneshot
      ExecStart=/run/current-system/sw/bin/systemctl restart systemd-resolved.service
    '';
  };

  # Proxy a subdomain to the container
  services.nginx.virtualHosts.${fractal.pihole.domain} = {
    forceSSL = true;
    enableACME = true;
    locations = {
      # Redirect root to the login page
      "= /" = {
        extraConfig = ''
          rewrite ^ /admin/login.php permanent;
        '';
      };

      # Pass everything to the container
      "/" = {
        proxyPass = "http://${fractal.pihole.ip}/";
        proxyWebsockets = true;
      };
    };
  };
}