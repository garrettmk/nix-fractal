{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    mdadm
  ];

  fileSystems = {
    backup = {
      device = "/dev/storage/backup";
      fsType = "ext4";
      mountPoint = "/mnt/storage/backup";
    };

    media = {
      device = "/dev/storage/media";
      fsType = "ext4";
      mountPoint = "/mnt/storage/media";
    };
  };
}