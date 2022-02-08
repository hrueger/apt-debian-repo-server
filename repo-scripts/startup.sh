#!/bin/bash

printf "\e[1;34m%-6s\e[m" "...::: Packet Sunucusu Başlatıldı :::..."
printf "\n"
mkdir -p /data/dists/focal/main/binary-amd64/
exec /usr/bin/supervisord -n
