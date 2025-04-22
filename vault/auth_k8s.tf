locals {
  k8s-clusters = {
    "k3s.fsn.as212024.net" = {
      endpoint       = "https://kubernetes.default.svc:443"
      ca_cert_base64 = "LS0tLS1CRUdJTiBFQyBQUklWQVRFIEtFWS0tLS0tCk1IY0NBUUVFSUtXZEFqVjdOSDVCT29XUW9lMFh6eUhZRTZDNTBoZXBhVUg0Mi9pQkMyS1pvQW9HQ0NxR1NNNDkKQXdFSG9VUURRZ0FFUVpQOFZTd0lMQitBTmtXdUhkOWwxV3ArczFtdUlLc2ovU3RmbDl2R1pJeGFmcGpsb1AvNAp4WjJPZUJPekRsMlNnWDJqaFhuR1YyZ3dENlM2OXoyeFJBPT0KLS0tLS1FTkQgRUMgUFJJVkFURSBLRVktLS0tLQo="
      extra_roles = {
        authentik = {
          sa_names      = ["authentik"]
          sa_namespaces = ["services-authentik"]
          policy        = <<-EOF
            path "${vault_mount.authentik.path}/data/*" {
              capabilities = ["create", "read", "update", "patch", "delete"]
            }
            path "auth/authentik/config" {
              capabilities = ["update"]
            }
          EOF
        }
      }
      pod_cidrs = [
        "172.28.128.0/22",
        "172.28.136.0/22",
        "2001:67c:17fc:110::/60",
      ]
    }
  }

  k8s-clusters_extra_roles_computed = merge([
    for cluster_name, cluster in local.k8s-clusters : {
      for role_name, role in try(cluster.extra_roles, {}) : "${cluster_name}_${role_name}" => merge(role, {
        cluster_name = cluster_name
        role_name    = role_name
        pod_cidrs    = try(cluster.pod_cidrs, [])
      })
    }
  ]...)
}

resource "vault_mount" "k8s-clusters" {
  for_each = local.k8s-clusters
  path     = "k8s-${each.key}"
  type     = "kv"
  options = {
    version = 2
  }
}

resource "vault_auth_backend" "k8s-clusters" {
  for_each = local.k8s-clusters
  type     = "kubernetes"
  path     = "k8s-${each.key}"
}

resource "vault_kubernetes_auth_backend_config" "k8s-clusters" {
  for_each               = local.k8s-clusters
  backend                = vault_auth_backend.k8s-clusters[each.key].path
  kubernetes_host        = each.value.endpoint
  kubernetes_ca_cert     = base64decode(each.value.ca_cert_base64)
  disable_iss_validation = true
}

resource "vault_policy" "k8s-clusters_common" {
  for_each = local.k8s-clusters
  name     = "k8s_${each.key}_common"
  policy   = <<-EOF
    path "${vault_mount.k8s-global.path}/data/global/*" {
      capabilities = ["read"]
    }
    path "${vault_mount.k8s-global.path}/data/{{identity.entity.aliases.${vault_auth_backend.k8s-clusters[each.key].accessor}.metadata.service_account_namespace}}/*" {
      capabilities = ["read"]
    }

    path "${vault_mount.k8s-clusters[each.key].path}/data/global/*" {
      capabilities = ["read"]
    }
    path "${vault_mount.k8s-clusters[each.key].path}/data/{{identity.entity.aliases.${vault_auth_backend.k8s-clusters[each.key].accessor}.metadata.service_account_namespace}}/*" {
      capabilities = ["read"]
    }

    path "${vault_mount.authentik.path}/data/providers/oauth2/k8s/global/{{identity.entity.aliases.${vault_auth_backend.k8s-clusters[each.key].accessor}.metadata.service_account_namespace}}" {
      capabilities = ["read"]
    }
    path "${vault_mount.authentik.path}/data/providers/oauth2/k8s/${each.key}/{{identity.entity.aliases.${vault_auth_backend.k8s-clusters[each.key].accessor}.metadata.service_account_namespace}}" {
      capabilities = ["read"]
    }
    path "${vault_mount.authentik.path}/data/providers/oauth2/k8s/global/{{identity.entity.aliases.${vault_auth_backend.k8s-clusters[each.key].accessor}.metadata.service_account_namespace}}/*" {
      capabilities = ["read"]
    }
    path "${vault_mount.authentik.path}/data/providers/oauth2/k8s/${each.key}/{{identity.entity.aliases.${vault_auth_backend.k8s-clusters[each.key].accessor}.metadata.service_account_namespace}}/*" {
      capabilities = ["read"]
    }
    path "${vault_mount.authentik.path}/data/tokens/k8s/global/{{identity.entity.aliases.${vault_auth_backend.k8s-clusters[each.key].accessor}.metadata.service_account_namespace}}" {
      capabilities = ["read"]
    }
    path "${vault_mount.authentik.path}/data/tokens/k8s/${each.key}/{{identity.entity.aliases.${vault_auth_backend.k8s-clusters[each.key].accessor}.metadata.service_account_namespace}}" {
      capabilities = ["read"]
    }
    path "${vault_mount.authentik.path}/data/tokens/k8s/global/{{identity.entity.aliases.${vault_auth_backend.k8s-clusters[each.key].accessor}.metadata.service_account_namespace}}/*" {
      capabilities = ["read"]
    }
    path "${vault_mount.authentik.path}/data/tokens/k8s/${each.key}/{{identity.entity.aliases.${vault_auth_backend.k8s-clusters[each.key].accessor}.metadata.service_account_namespace}}/*" {
      capabilities = ["read"]
    }

    %{for postgres_cluster in keys(local.postgres_clusters)}
    path "${vault_database_secrets_mount.postgres.path}/creds/${postgres_cluster}_${each.key}_{{identity.entity.aliases.${vault_auth_backend.k8s-clusters[each.key].accessor}.metadata.service_account_namespace}}" {
      capabilities = ["read"]
    }
    path "${vault_database_secrets_mount.postgres.path}/creds/${postgres_cluster}_${each.key}_{{identity.entity.aliases.${vault_auth_backend.k8s-clusters[each.key].accessor}.metadata.service_account_namespace}}_*" {
      capabilities = ["read"]
    }
    path "${vault_database_secrets_mount.postgres.path}/static-creds/${postgres_cluster}_${each.key}_{{identity.entity.aliases.${vault_auth_backend.k8s-clusters[each.key].accessor}.metadata.service_account_namespace}}" {
      capabilities = ["read"]
    }
    path "${vault_database_secrets_mount.postgres.path}/static-creds/${postgres_cluster}_${each.key}_{{identity.entity.aliases.${vault_auth_backend.k8s-clusters[each.key].accessor}.metadata.service_account_namespace}}_*" {
      capabilities = ["read"]
    }
    %{endfor}
  EOF
}

resource "vault_kubernetes_auth_backend_role" "k8s-clusters_common" {
  for_each                         = local.k8s-clusters
  backend                          = vault_auth_backend.k8s-clusters[each.key].path
  role_name                        = "common"
  bound_service_account_names      = ["*"]
  bound_service_account_namespaces = ["*"]
  token_policies                   = [vault_policy.k8s-clusters_common[each.key].name]
  token_ttl                        = 24 * 60 * 60 # 24h
  token_bound_cidrs                = try(each.value.pod_cidrs, [])
}

resource "vault_policy" "k8s-clusters_extra-roles" {
  for_each = local.k8s-clusters_extra_roles_computed

  name   = "k8s-clusters_${each.key}"
  policy = each.value.policy
}
resource "vault_kubernetes_auth_backend_role" "k8s-clusters_extra-roles" {
  for_each                         = local.k8s-clusters_extra_roles_computed
  backend                          = vault_auth_backend.k8s-clusters[each.value.cluster_name].path
  role_name                        = each.value.role_name
  bound_service_account_names      = each.value.sa_names
  bound_service_account_namespaces = each.value.sa_namespaces
  token_policies                   = [vault_policy.k8s-clusters_extra-roles[each.key].name]
  token_ttl                        = 24 * 60 * 60 # 24h
  token_bound_cidrs                = each.value.pod_cidrs
}
