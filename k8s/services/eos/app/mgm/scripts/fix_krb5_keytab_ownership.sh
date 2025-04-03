#!/usr/bin/env bash

set -xeuo pipefail

base64 -d < /root/krb5_keytab/input/keytab > /root/krb5_keytab/output/eos.krb5.keytab
chown daemon:daemon /root/krb5_keytab/output/eos.krb5.keytab
