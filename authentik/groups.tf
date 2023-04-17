data "authentik_group" "groups" {
  for_each = toset([
    "roots",
    "service-accounts",
    "authentik Admins",
  ])
  name = each.key
}
