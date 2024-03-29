{ config, pkgs, ... }:

let
  fractal = config.fractal;
in {
  environment.systemPackages = with pkgs; [
    dig
    openssl
    nginx
    tcpdump
    tshark
    traceroute
    tcptraceroute
  ];

  #
  # Basic networking
  #
  networking = {
    # This worked, and now it doesn't....?
    # Set the hostname and static IP address
    # hostName = fractal.hostName;
    # interfaces.eth0 = {
    #   useDHCP = false;
    #   ipv4.addresses = [
    #     {
    #       address = fractal.hostIp;
    #       prefixLength = 24;
    #     }
    #   ];
    # };

    # Of course
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 443 ];
      allowedUDPPorts = [];
    };

    hosts = {
      "192.168.0.11" = [ "caladan.home" ];
      ${fractal.hostIp} = [ fractal.hostDomain ];
    };
  };

  # nginx
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    # recommendedOptimisation = true;
    # recommendedGzipSettings = true;

    defaultListenAddresses = [
      fractal.hostIp
    ];

    virtualHosts."default" = {
      default = true;
      serverName = "_";

      locations = {
        "/" = {
          return = "404";
        };
      };
    };
  };
}