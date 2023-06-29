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
      ./storage.nix
      ./networking.nix
      # ./certificates.nix
      # ./containers.nix
      ./base.nix
      # ./home-manager.nix
      # ./users.nix
      # ./step-ca.nix
      # ./pihole.nix
      # ./monitoring.nix
      # ./vscode-server.nix
      # ./nextcloud.nix
    ];
}

