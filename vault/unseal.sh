#!/usr/bin/env bash

vault operator unseal -reset > /dev/null || true
jq -r '.unseal_keys_b64[]' < secrets/vault.json | while read -r key; do
    vault operator unseal "${key}"
done
