#!/bin/bash

printf '\e[1;34m%-6s\e[m' "...::: Paket Sunucusu Başlatıldı :::..."
printf "\n"
mkdir -p /data/dists/focal/main/binary-amd64/
exec /usr/bin/supervisord -n
