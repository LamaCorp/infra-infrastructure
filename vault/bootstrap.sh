#!/usr/bin/env bash

# Bootstrap script for Vault. Must only be run once after Vault installation.

export VAULT_ADDR="https://vault.lama.tel:443"

mkdir -p secrets

# Initialize the vault
vault_keys="$(vault operator init -key-shares=5 -key-threshold=3 -format=json)"
echo "${vault_keys}" | jq > secrets/vault.json

# Unseal it
vault operator unseal -reset > /dev/null || true
jq -r '.unseal_keys_b64[]' < secrets/vault.json | while read -r key; do
    vault operator unseal "${key}"
done

# Login so we can run the Terraform
vault login -non-interactive -no-print "$(jq -r '.root_token' < secrets/vault.json)"
