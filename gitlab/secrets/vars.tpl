# GitLab Terraform backend

## Create those with
## https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html with the
## API scope

export GITLAB_USERNAME="FIXME"
export GITLAB_ACCESS_TOKEN="FIXME"


# GitLab authentication

## You can create a new token here or use the same as above, it doesn't really
## make a difference.
export TF_VAR_gitlab_token="${GITLAB_ACCESS_TOKEN}"


# GitHub authentication
export TF_VAR_github_token="FIXME"

# GitHub mirroring authentication
export TF_VAR_github_mirroring_token="FIXME"
