#!/usr/bin/env bash

set -euo pipefail

GITLAB_PROJECT_ID="${GITLAB_PROJECT_ID:-43430286}"
GITLAB_STATE_NAME="${GITLAB_STATE_NAME:-vault}"

echo "Current settings:"
echo "  GitLab project ID: ${GITLAB_PROJECT_ID}"
echo "  GitLab Terraform state name: ${GITLAB_STATE_NAME}"

terraform init \
  -upgrade \
  -backend-config="address=https://gitlab.com/api/v4/projects/${GITLAB_PROJECT_ID}/terraform/state/${GITLAB_STATE_NAME}" \
  -backend-config="lock_address=https://gitlab.com/api/v4/projects/${GITLAB_PROJECT_ID}/terraform/state/${GITLAB_STATE_NAME}/lock" \
  -backend-config="unlock_address=https://gitlab.com/api/v4/projects/${GITLAB_PROJECT_ID}/terraform/state/${GITLAB_STATE_NAME}/lock" \
  -backend-config="username=${GITLAB_USERNAME}" \
  -backend-config="password=${GITLAB_ACCESS_TOKEN}" \
  -backend-config="lock_method=POST" \
  -backend-config="unlock_method=DELETE" \
  -backend-config="retry_wait_min=5" \
  "$@"
