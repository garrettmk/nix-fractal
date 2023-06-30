{ config, pkgs, ... }:

let
  fractal = config.fractal;
  stateVersion = config.system.stateVersion;
in {

  # Make an admin user
  users.users.garrett = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    packages = with pkgs; [
      firefox
      tree
    ];
  };

  # Set up some git defaults
  home-manager.users.garrett = {
    home.stateVersion = stateVersion;
    programs = {
      git = {
        enable = true;
        userName = "Garrett Myrick";
        userEmail = "garrettmyrick@gmail.com";
      };
    };
  };
}