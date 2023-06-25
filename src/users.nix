{ config, pkgs, ... }:

{
  users.users.garrett = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    packages = with pkgs; [
      firefox
      tree
    ];
  };

  home-manager.users.garrett = {
    home.stateVersion = "23.05";
    programs = {
      git = {
        enable = true;
        userName = "Garrett Myrick";
        userEmail = "garrettmyrick@gmail.com";
      };
    };
  };
}