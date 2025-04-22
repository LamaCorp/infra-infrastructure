locals {
  users = {
    hedgedoc = {
      k8s_cluster    = "k3s.fsn.as212024.net"
      k8s_namespaces = ["services-hedgedoc"]
    }
    lemmy = {
      k8s_cluster    = "k3s.fsn.as212024.net"
      k8s_namespaces = ["services-lemmy"]
    }
    loki = {
      k8s_cluster    = "k3s.fsn.as212024.net"
      k8s_namespaces = ["infra-observability"]
    }
    mastodon = {
      k8s_cluster    = "k3s.fsn.as212024.net"
      k8s_namespaces = ["services-mastodon"]
    }
    matrix = {
      k8s_cluster    = "k3s.fsn.as212024.net"
      k8s_namespaces = ["services-matrix"]
    }
    mattermost = {
      k8s_cluster    = "k3s.fsn.as212024.net"
      k8s_namespaces = ["services-mattermost"]
    }
    nix-cache = {}
    thanos = {
      k8s_cluster    = "global"
      k8s_namespaces = ["core-observability", "infra-observability"]
    }
    upsilon = {}
    velero = {
      k8s_cluster    = "global"
      k8s_namespaces = ["core-velero"]
    }
  }

  users_computed = {
    for username, user in local.users :
    username => merge(user, {
      username    = username
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

resource "vault_generic_secret" "s3_users_k8s" {
  for_each = merge([
    for k, v in local.users_computed : {
      for k8s_namespace in try(v.k8s_namespaces, []) : "${k}_${v.k8s_cluster}_${k8s_namespace}" => merge(v, {
        k8s_cluster   = v.k8s_cluster
        k8s_namespace = k8s_namespace
      })
    }
  ]...)
  path = "k8s-${each.value.k8s_cluster}/${each.value.k8s_namespace}/s3-${each.value.username}"
  data_json = jsonencode(merge(each.value, {
    access_key = random_password.access_key[each.value.username].result
    secret_key = random_password.secret_key[each.value.username].result
  }))
}

resource "vault_generic_secret" "k8s-k3s-fsn-as212024-net_services-cloudserver_authdata" {
  path = "k8s-k3s.fsn.as212024.net/services-cloudserver/authdata"
  data_json = jsonencode({
    "authdata.json" = jsonencode({
      accounts = [
        for _, v in local.users_computed : {
          name        = v.username
          email       = v.email
          arn         = v.arn
          canonicalID = v.canonicalID
          shortid     = v.shortid
          keys = [{
            access = random_password.access_key[v.username].result
            secret = random_password.secret_key[v.username].result
          }]
        }
      ]
    })
  })
}
