{ config, pkgs, ... }:

{
  # Set up the pre-existing RAID
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

  # See https://github.com/NixOS/nixpkgs/issues/72394#issuecomment-549110501
  environment.etc."mdadm.conf".text = ''
    MAILADDR root
  '';

  systemd.tmpfiles.rules = [
    "d /mnt 0777 root root -"
    "d /mnt/storage 0777 root root -"
    "d /mnt/storage/backup 0777 root root -"
    "d /mnt/storage/media 0777 root root -"
  ];
}