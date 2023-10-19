#!/run/current-system/sw/bin/bash

cp /etc/nixos/hardware-configuration.nix /tmp
rm -rf /etc/nixos/*
cp -r ./src/* /etc/nixos
mv /tmp/hardware-configuration.nix /etc/nixos

rm -rf /var/lib/secrets
cp -r --preserve=ownership ./secrets /var/lib

rm -rf /var/lib/acme/*

nixos-rebuild switch