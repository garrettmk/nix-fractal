#!/run/current-system/sw/bin/bash

parted /dev/vda -- mklabel gpt
parted /dev/vda -- mkpart primary 512MiB -8GiB
parted /dev/vda -- mkpart primary linux-swap -8GiB 100%
parted /dev/vda -- mkpart ESP fat32 1MiB 512MiB
parted /dev/vda -- set 3 esp on

mkfs.xfs -f -L nixos /dev/vda1
mkswap -L swap /dev/vda2
mkfs.fat -F 32 -n boot /dev/vda3

mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot
swapon /dev/vda2

nixos-generate-config --root /mnt
sed -i 's/alice/garrett/g' /mnt/etc/nixos/configuration.nix
sed -i '/firefox/d' /mnt/etc/nixos/configuration.nix