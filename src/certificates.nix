{ config, pkgs, ... }:

{
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