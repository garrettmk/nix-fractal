{ config, pkgs, ... }:

let
  fractal = config.fractal;
in {
  environment.systemPackages = with pkgs; [
    dig
    openssl
    nginx
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

    # Add ourselves and other known hosts to the hosts
    # file so we can refer to the by name
    hosts = {
      "192.168.0.11" = ["caladoon.home"];
      "${fractal.hostIp}" = ["${fractal.hostDomain}"];
    };

    # Of course
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 443 ];
      allowedUDPPorts = [];
    };
  };

  # nginx
  services.nginx = {
    enable = true;
  };
}