#!/usr/bin/env bash

set -xeuo pipefail

cp /root/sss_keytab/input/eos.keytab /root/sss_keytab/output/eos.keytab
chown daemon:daemon /root/sss_keytab/output/eos.keytab
chmod 400 /root/sss_keytab/output/eos.keytab
