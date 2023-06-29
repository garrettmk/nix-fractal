{ config, pkgs, ... }:

let
  fractal = config.fractal;
  stateVersion = config.system.stateVersion;
in {
  systemd.tmpfiles.rules = [
    "d ${fractal.step-ca.dataPath} 777"
  ];

  networking.hosts = {
    "192.168.100.21" = [ fractal.step-ca.domain ];
  };

  containers.step-ca = {
    ephemeral = true;
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.100.20";
    localAddress = fractal.step-ca.ip;

    bindMounts = {
      "/var/lib/private/step-ca" = {
        hostPath = "${fractal.step-ca.dataPath}";
        isReadOnly = false;
      };
    };

    extraFlags = [
      "--private-users=yes"
    ];

    config = { config, pkgs, ... }: {
      system.stateVersion = stateVersion;
      
      environment = {
        etc."resolv.conf".text = "nameserver ${fractal.hostIp}";
        systemPackages = with pkgs; [
          step-ca
          step-cli
        ];
      };

      networking = {
        firewall.enable = false;
        hosts = {
          "127.0.0.1" = [ fractal.step-ca.domain ];
        };
      };

      services.step-ca = {
        enable = true;
        openFirewall = true;
        port = 443;
        address = "0.0.0.0";
        intermediatePasswordFile = "/var/lib/step-ca/secrets/intermediatePasswordFile";
        settings = builtins.fromJSON ''
          {
            "root": "/var/lib/step-ca/certs/root_ca.crt",
            "federatedRoots": null,
            "crt": "/var/lib/step-ca/certs/intermediate_ca.crt",
            "key": "/var/lib/step-ca/secrets/intermediate_ca_key",
            "address": ":443",
            "insecureAddress": "",
            "dnsNames": [
              "${fractal.step-ca.domain}"
            ],
            "logger": {
              "format": "text"
            },
            "db": {
              "type": "badgerv2",
              "dataSource": "/var/lib/step-ca/db",
              "badgerFileLoadingMode": ""
            },
            "authority": {
              "provisioners": [
                {
                  "type": "JWK",
                  "name": "admin@nix-fractal.home",
                  "key": {
                    "use": "sig",
                    "kty": "EC",
                    "kid": "IpE7BWAV5h9flUxE0X8P1braOhnT2-Cit5LsfRbI2z8",
                    "crv": "P-256",
                    "alg": "ES256",
                    "x": "P8BnVscZD1SIRLQGfvqwcDi3ea6ocjnZPJEQ3gCfZXk",
                    "y": "y1o64WDq98V2RAdfQB_3oF0YTiUdDHtNVyPKbAyfI4E"
                  },
                  "encryptedKey": "eyJhbGciOiJQQkVTMi1IUzI1NitBMTI4S1ciLCJjdHkiOiJqd2sranNvbiIsImVuYyI6IkEyNTZHQ00iLCJwMmMiOjEwMDAwMCwicDJzIjoiTGR5SlZMRS1Kc1E2SGhjLWVnYUdtZyJ9.hoXZxThvIC4qegKofYeh3uazhtqvqWnWzA1WlF_o_ZXJnMVxUgSbXQ.ykx58DTvtqNDvAfn.DPmDyi7j32LqXwQ3JSxIYYnNsiGzTCZYRQ_4isAg3qWpFkNsJFIroEpwUlDRch5NRqbX6NJdsmuPIcxWebJERepY-xUzu-jnsCPDMZWx2hLiYr5kxHhy56EisFX1aquf-RNCWLB3rSjNUSt5YtWhP4edWWLdAVRPgtSGuCG2UBxXm1Js6MvrShe9ABZ7IKEKUGEGSiLtwomxzSDy4FnH0ooYnNF-qWqGkJ-2-VjRgeQlKCZD94NVmuzVHN2mREX9Nn1KjTmLHP9CIV2IMH8GAJ0WovLkrJX_jgyf5tDnakFKpbtMFB2AEyIsspPLF6TsCUVo9DkT05suSpnbkbQ.zcgv4j7xw9U_nZQ6HpcvnA"
                },
                {
                  "type": "ACME",
                  "name": "acme"
                }
              ]
            },
            "tls": {
              "cipherSuites": [
                "TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256",
                "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256"
              ],
              "minVersion": 1.2,
              "maxVersion": 1.3,
              "renegotiation": false
            }
          }
        '';
      };
    };
  };
}


# PW: h1|.VI.xP=MUi!!@}e!6M_F#y[p>cW}{