#!/usr/bin/env bash

set -euo pipefail

wasabi_credentials="$(vault kv get -format=json restic/wasabi-credentials | jq '.data.data')"

cat <<EOF > minio.env
MINIO_ROOT_USER=$(jq -r '.access_key' <<< "${wasabi_credentials}")
MINIO_ROOT_PASSWORD=$(jq -r '.secret_key' <<< "${wasabi_credentials}")
EOF
