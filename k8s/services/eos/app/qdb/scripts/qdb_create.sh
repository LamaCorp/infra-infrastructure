#!/usr/bin/env bash

set -xeuo pipefail

if [ ! -d /var/quarkdb/node-0 ]; then
  quarkdb-create --path /var/quarkdb/node-0
  chown -R daemon:daemon /var/quarkdb/node-0
fi
