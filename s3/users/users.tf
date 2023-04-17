locals {
  users = {
    hedgedoc   = {}
    loki       = {}
    matrix     = {}
    mattermost = {}
    nix-cache  = {}
    thanos     = {}
    upsilon    = {}
  }

  users_computed = {
    for username, user in local.users :
    username => merge(user, {
      email       = "${username}@s3.lama-corp.space"
      arn         = "arn:aws:iam::${random_integer.arn_id[username].result}:root"
      shortid     = tostring(random_integer.arn_id[username].result)
      canonicalID = "${random_integer.canonical_id_start[username].result}${random_id.canonical_id[username].hex}"
    })
  }
}

resource "random_integer" "arn_id" {
  for_each = local.users
  min      = 100000000000
  max      = 999999999999
}

resource "random_integer" "canonical_id_start" {
  for_each = local.users
  min      = 10
  max      = 99
}

resource "random_id" "canonical_id" {
  for_each    = local.users
  byte_length = 31
}

data "assert_test" "shortid_uniqueness" {
  test  = length([for _, user in local.users_computed : user.shortid]) == length(toset([for _, user in local.users_computed : user.shortid]))
  throw = "All users shortid where not unique, try again."
}

data "assert_test" "canonical_id_uniqueness" {
  test  = length([for _, user in local.users_computed : user.canonicalID]) == length(toset([for _, user in local.users_computed : user.canonicalID]))
  throw = "All users canonicalID where not unique, try again."
}

resource "random_password" "access_key" {
  for_each = local.users
  length   = 32
  special  = false
}

resource "random_password" "secret_key" {
  for_each = local.users
  length   = 64
  special  = false
}

resource "vault_generic_secret" "s3_users" {
  for_each = local.users_computed
  path     = "s3/users/${each.key}"
  data_json = jsonencode(merge(each.value, {
    access_key = random_password.access_key[each.key].result
    secret_key = random_password.secret_key[each.key].result
  }))
}
