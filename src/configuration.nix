{ inputs, pkgs, ... }:

{
  nix.settings.experimental-features = ["nix-command" "flakes"];
  system.stateVersion = "23.05";
  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-23.05";
  
  imports =
    [
      ./options.nix
      ./hardware-configuration.nix
      ./boot.nix
      ./base.nix
      ./containers.nix
      ./home-manager.nix
      ./users.nix
      ./storage.nix
      ./networking.nix
      ./dns.nix
      ./ca.nix
      ./acme.nix
      ./monitoring.nix
      # ./vscode-server.nix
      # ./nextcloud.nix
    ];
}

