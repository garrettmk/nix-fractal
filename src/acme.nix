{ config, pkgs, ... }:

let
  fractal = config.fractal;
in {
  # Set up the ACME client to work with the CA
  security.acme = {
    acceptTerms = true;
    defaults = {
      # Since we're not actually using LetsEncrypt, email isn't used for anything;
      # But it's still required and must have a valid public TLD
      email = "admin+acme@${fractal.hostName}.org";
      server = "https://${fractal.ca.domain}:${toString fractal.ca.port}/acme/acme/directory";
      webroot = "/var/lib/acme/acme-challenge";
    };
  };

  # Make sure nginx can read the cert files
  users.users.nginx.extraGroups = [ "acme" ];

  # ACME challenge requests, for any domain on nix-fractal,
  # get served from /var. Otherwise use other proxy rules.
  services.nginx = {
    virtualHosts = {
      "acme.${fractal.hostDomain}" = {
        serverAliases = [ "*.${fractal.hostDomain}" ];
        # Match all subdomains *except* ca.xxx.xxx
        # serverAliases = [ "~^(?!ca\.).+\.${fractal.hostName}\.${fractal.hostTLD}$" ];

        locations = {
          # Serve ACME challenge responses from /var
          "/.well-known/acme-challenge" = {
            root = "/var/lib/acme/acme-challenge";
          };

          # For everything else defer to other rules
          "/" = {
            return = "301 https://$host$request_uri";
          };
        };
      };
    };
  };
}