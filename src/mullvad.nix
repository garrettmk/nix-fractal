{ config, pkgs, ... }:

let
  fractal = config.fractal;
in {

  environment.systemPackages = with pkgs; [
    wireguard-tools
  ];

  containers.mullvad = {
    autoStart = true;
    ephemeral = true;
    privateNetwork = true;
    hostAddress = "192.168.111.10";
    localAddress = "192.168.111.11";

    bindMounts = {
      "/var/lib/secrets" = {
        hostPath = "/var/lib/secrets";
      };
    };

    config = { config, pkgs, ... }: {
      system.stateVersion = "23.05";
      networking.wireguard.enable = true;
      networking.wg-quick = fractal.mullvad.wg-quick;
    };
  };
}