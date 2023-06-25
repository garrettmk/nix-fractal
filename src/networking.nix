{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    dig
  ];

  networking = {
    hostName = "nix-fractal";

    # Resolve hosts on the local network by name
    hosts = {
      "192.168.0.11" = ["caladoon.home"];
    };

    firewall = {
      enable = true;
      allowedTCPPorts = [ 
        53                  # Allow DNS queries from outside
        9080                # Pihole
      ];
      allowedUDPPorts = [
        53
      ];
    };
  };

  services.resolved = {
    enable = true;
    domains = ["~."];
    
    # Use only the Pihole container for DNS resolution
    # Tell the stub listener to allow DNS queries from the local network
    extraConfig = ''
      [Resolve]
      DNS=10.88.0.53
      FallbackDNS=
      DNSStubListener=yes
      DNSStubListenerExtra=192.168.122.19
    '';
  };
  
  virtualisation.oci-containers.containers.pihole = {
    image = "docker.io/pihole/pihole";
    autoStart = true;
    ports = [ "9080:80" ];
    volumes = ["pihole-data:/etc/pihole"];
    environment = {
      WEBPASSWORD = "admin";
      TZ = "America/Los_Angeles";
    };
    extraOptions = [
      "--cap-add=NET_ADMIN"
      "--ip=10.88.0.53"
    ];
  };
}