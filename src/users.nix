{ config, pkgs, ... }:

let
  fractal = config.fractal;
  stateVersion = config.system.stateVersion;
in {
  users.users.garrett = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    packages = with pkgs; [
      firefox
      tree
    ];
  };

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