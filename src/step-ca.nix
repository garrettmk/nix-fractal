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
          "${fractal.step-ca.ip}" = [ fractal.step-ca.domain ];
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
              "ca.nix-fractal.home"
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
                  "name": "admin@nix-fractal.org",
                  "key": {
                    "use": "sig",
                    "kty": "EC",
                    "kid": "UuEhJiFWfFostX8ArUQQd4b29T3E-bxhpTEeoInp61c",
                    "crv": "P-256",
                    "alg": "ES256",
                    "x": "Wc0RhBMc0O0yBKCm9ltv9-UBCGicaGmIRTJHEUm_gWg",
                    "y": "NDQQRuSnaytvRlU-Q71BIkyZP13_WtLKD8tsegRm80I"
                  },
                  "encryptedKey": "eyJhbGciOiJQQkVTMi1IUzI1NitBMTI4S1ciLCJjdHkiOiJqd2sranNvbiIsImVuYyI6IkEyNTZHQ00iLCJwMmMiOjEwMDAwMCwicDJzIjoiVV9lVWZsOHVlaFFzblVpQVl2aTRoZyJ9.8cikEMqw71huK1aapO-yRlTGdSQ4Qh1UPTUjpIJfR8r9qxz3Zm9ZDQ.Ez4P6jYPDiZA_dE8.apAfNDu_RjHbz3XTSpolfwjw-JGe5f3jsu8c6qke3X9ypkIjEophkKeiCNB97vBiksN62SvfE_FMqm2zgIx8_-VZFCIUZ0LhrVCXE-0qG2zCmBYx1XXt__uJPk5IVJ5mRrKveaeC4_IfWdtHvxJMGFz1wslld5fjRhozrYzICIki8xkTeBgHHP_Hvr52e89NWhCIa2i7hwHM6uVwLejZ2gUonmYeQIOBCnOl9AWZw69tGA0oz65SLuM5MV8xOlJRpAPPQP5Tt8dHeL7cqbx8g8GVKfYi0ViKQ0Tsgz9sZz_1oD5v5oqRfB-Owr_05eq4c_Q-m8t5RY0ooTifCOk.xffQohV8HievmnUMGKFcLQ"
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