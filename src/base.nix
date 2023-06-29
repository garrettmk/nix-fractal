{ inputs, pkgs, ... }:

let
  fractal = config.fractal;
in {

  # Install some basic utilities
  environment.systemPackages = with pkgs; [
    vim
    nano
    wget
    podman
    git
  ];

  # Set locale settings
  time.timeZone = config.fractal.timeZone;
  i18n.defaultLocale = config.fractal.locale;

  # Make sure we have SSH
  services.openssh = {
    enable = true;
  };

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
}