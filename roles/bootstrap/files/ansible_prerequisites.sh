#!/bin/sh

set -e

if [ ! -f "/var/.ansible_prerequisites_installed" ]; then
    apt-get update
    apt-get install -y --no-install-recommends python3
    touch /var/.ansible_prerequisites_installed
fi
