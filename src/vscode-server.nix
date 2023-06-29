{ config, pkgs, ... }:

{
  imports = [
    (fetchTarball "https://github.com/nix-community/nixos-vscode-server/tarball/master")
  ];

  environment.systemPackages = with pkgs; [
    nodejs
  ];

  services.vscode-server.enable = true;
  systemd.user.services.auto-fix-vscode-server.enable = true;
}