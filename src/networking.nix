{ config, pkgs, ... }:

let
  fractal = config.fractal;
in {
  environment.systemPackages = with pkgs; [
    dig
    openssl
  ];

  #
  # Basic networking
  #
  networking = {
    # Set the hostname and static IP address
    hostName = fractal.hostName;
    interfaces.eth0 = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = fractal.hostIp;
          prefixLength = 24;
        }
      ];
    };

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

    # Required for containers to have internet
    nat = {
      enable = true;
      internalInterfaces = [ "ve-+" ];
      externalInterface = "enp1s0";
      enableIPv6 = true;
    };
  };


  #
  # Certificates and trust
  #

  # Make sure we trust our CA
  security.pki.certificateFiles = [
    ./pki/roots.pem
  ];

  # Set up the ACME client to work with the CA
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "admin+acme@${fractal.hostName}.org"; # Not used but must be valid (hence .org)
      server = "https://${fractal.step-ca.domain}/acme/acme/directory";
      webroot = "/var/lib/acme/acme-challenge";
    };
  };

  # Make sure nginx can read the cert files
  users.users.nginx.extraGroups = [ "acme" ];

  # ACME challenge requests, for any domain on nix-fractl,
  # get served from /var. Otherwise use other proxy rules.
  services.nginx = {
    enable = true;
    virtualHosts = {
      "default" = {
        serverName = "_";
        serverAliases = [ "*.${fractal.hostDomain}" ];
        locations = {
          "/.well-known/acme-challenge" = {
            root = "/var/lib/acme/acme-challenge";
          };

          "/" = {
            return = "301 https://$host$request_uri";
          };
        };
      };
    };
  };

}