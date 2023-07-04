#!/run/current-system/sw/bin/bash

rm -rf /etc/nixos/*
cp -r ./src/* /etc/nixos

rm -rf /var/lib/secrets
cp -r --preserve=ownership ./secrets /var/lib

rm -rf /var/lib/acme/*

nixos-rebuild switch