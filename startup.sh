#!/bin/bash

mkdir -p /data/dists/focal/main/binary-amd64/
exec /usr/bin/supervisord -n
