locals {
  prometheus_allowed_groups = [
    "roots",
  ]
}

resource "authentik_application" "prometheus" {
  name               = "Prometheus"
  slug               = "prometheus"
  group              = "Infra"
  policy_engine_mode = "any"

  meta_launch_url  = "https://prometheus.lama.tel"
  meta_icon        = "https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/prometheus.png"
  meta_description = "Metrics aggregator"
}

resource "authentik_policy_binding" "prometheus_group-filtering" {
  for_each = { for idx, value in local.prometheus_allowed_groups : idx => value }

  target = authentik_application.prometheus.uuid
  group  = data.authentik_group.groups[each.value].id
  order  = each.key
}
