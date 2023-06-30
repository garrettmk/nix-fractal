{ config, pkgs, ... }:

let
  fractal = config.fractal;
in {

  # Install packages
  environment.systemPackages = with pkgs; [
    podman
  ];

  # Set up podman
  virtualisation = {
    podman = {
      enable = true;
      defaultNetwork.settings = {
        dns_enabled = true;
      };
    };

    oci-containers = {
      backend = "podman";
      containers = {};
    };
  };

  # Required for systemd containers to have internet
  networking = {
    nat = {
      enable = true;
      internalInterfaces = [ "ve-+" ];
      externalInterface = "enp1s0";
      enableIPv6 = true;
    };
  };
}