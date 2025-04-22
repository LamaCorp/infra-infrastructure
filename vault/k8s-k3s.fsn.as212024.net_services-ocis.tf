resource "random_password" "k8s-k3s-fsn-as212024-net_services-ocis_jwt-secret" {
  count   = 1
  length  = 64
  special = false
}
resource "vault_generic_secret" "k8s-k3s-fsn-as212024-net_services-ocis_jwt-secret" {
  path = "${vault_mount.k8s-clusters["k3s.fsn.as212024.net"].path}/services-ocis/jwt-secret"
  data_json = jsonencode({
    jwt-secret = random_password.k8s-k3s-fsn-as212024-net_services-ocis_jwt-secret[0].result
  })
}

resource "random_password" "k8s-k3s-fsn-as212024-net_services-ocis_machine-auth-api-key" {
  count   = 1
  length  = 64
  special = false
}
resource "vault_generic_secret" "k8s-k3s-fsn-as212024-net_services-ocis_machine-auth-api-key" {
  path = "${vault_mount.k8s-clusters["k3s.fsn.as212024.net"].path}/services-ocis/machine-auth-api-key"
  data_json = jsonencode({
    machine-auth-api-key = random_password.k8s-k3s-fsn-as212024-net_services-ocis_machine-auth-api-key[0].result
  })
}

resource "random_uuid" "k8s-k3s-fsn-as212024-net_services-ocis_storage-system" {
  count = 1
}
resource "random_password" "k8s-k3s-fsn-as212024-net_services-ocis_storage-system" {
  count   = 1
  length  = 64
  special = false
}
resource "vault_generic_secret" "k8s-k3s-fsn-as212024-net_services-ocis_storage-system" {
  path = "${vault_mount.k8s-clusters["k3s.fsn.as212024.net"].path}/services-ocis/storage-system"
  data_json = jsonencode({
    user-id = random_uuid.k8s-k3s-fsn-as212024-net_services-ocis_storage-system[0].result
    api-key = random_password.k8s-k3s-fsn-as212024-net_services-ocis_storage-system[0].result
  })
}

resource "random_password" "k8s-k3s-fsn-as212024-net_services-ocis_storage-system-jwt-secret" {
  count   = 1
  length  = 64
  special = false
}
resource "vault_generic_secret" "k8s-k3s-fsn-as212024-net_services-ocis_storage-system-jwt-secret" {
  path = "${vault_mount.k8s-clusters["k3s.fsn.as212024.net"].path}/services-ocis/storage-system-jwt-secret"
  data_json = jsonencode({
    storage-system-jwt-secret = random_password.k8s-k3s-fsn-as212024-net_services-ocis_storage-system-jwt-secret[0].result
  })
}

resource "random_password" "k8s-k3s-fsn-as212024-net_services-ocis_transfer-secret" {
  count   = 1
  length  = 64
  special = false
}
resource "vault_generic_secret" "k8s-k3s-fsn-as212024-net_services-ocis_transfer-secret" {
  path = "${vault_mount.k8s-clusters["k3s.fsn.as212024.net"].path}/services-ocis/transfer-secret"
  data_json = jsonencode({
    transfer-secret = random_password.k8s-k3s-fsn-as212024-net_services-ocis_transfer-secret[0].result
  })
}

resource "random_password" "k8s-k3s-fsn-as212024-net_services-ocis_thumbnails-transfer-secret" {
  count   = 1
  length  = 64
  special = false
}
resource "vault_generic_secret" "k8s-k3s-fsn-as212024-net_services-ocis_thumbnails-transfer-secret" {
  path = "${vault_mount.k8s-clusters["k3s.fsn.as212024.net"].path}/services-ocis/thumbnails-transfer-secret"
  data_json = jsonencode({
    thumbnails-transfer-secret = random_password.k8s-k3s-fsn-as212024-net_services-ocis_thumbnails-transfer-secret[0].result
  })
}
