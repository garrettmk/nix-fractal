{ inputs, pkgs, ... }:

{
  nix.settings.experimental-features = ["nix-command" "flakes"];
  system.stateVersion = "23.05";
  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-${system.stateVersion}";
  
  imports =
    [
      ./options.nix
      ./hardware-configuration.nix
      ./boot.nix
      ./base.nix
      ./storage.nix
      ./networking.nix
      # ./home-manager.nix
      # ./users.nix
      # ./step-ca.nix
      # ./pihole.nix
      # ./monitoring.nix
      # ./vscode-server.nix
      # ./nextcloud.nix
    ];
}

