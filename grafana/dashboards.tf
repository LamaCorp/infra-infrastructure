locals {
  folders = {
    common = {
      title = "Common"
    }
    django = {
      title = "Django"
    }
    logging = {
      title = "Logging (Loki/Promtail)"
    }
    monitoring = {
      title = "Monitoring (Prometheus/Thanos/Alertmanager)"
    }
    network = {
      title = "Network"
    }
    postgresql = {
      title = "PostgreSQL"
    }
    redis = {
      title = "Redis"
    }
  }

  dashboards = {
    common = {
      authentik = {
        tags = ["authentik"]
      }
      nodes = {
        tags = ["node-exporter"]
      }
      vault = {
        tags = ["vault"]
      }
      zfs = {
        tags = ["zfs"]
      }
    }

    django = {
      django-overview = {
        tags = ["django"]
      }
      django-requests-overview = {
        tags = ["django"]
      }
      django-requests-by-view = {
        tags = ["django"]
      }
    }

    logging = {
      loki-chunks = {
        tags = ["loki"]
      }
      loki-deletion = {
        tags = ["loki"]
      }
      loki-logs = {
        tags = ["loki"]
      }
      loki-operational = {
        tags = ["loki"]
      }
      loki-reads = {
        tags = ["loki"]
      }
      loki-reads-resources = {
        tags = ["loki"]
      }
      loki-recording-rules = {
        tags = ["loki"]
      }
      loki-retention = {
        tags = ["loki"]
      }
      loki-writes = {
        tags = ["loki"]
      }
      loki-writes-resources = {
        tags = ["loki"]
      }
    }

    monitoring = {
      alertmanager = {
        tags = ["alertmanager"]
      }
      prometheus = {
        tags = ["prometheus"]
      }
      thanos-bucket-replicate = {
        tags = ["thanos"]
      }
      thanos-compact = {
        tags = ["thanos"]
      }
      thanos-overview = {
        tags = ["thanos"]
      }
      thanos-query-frontend = {
        tags = ["thanos"]
      }
      thanos-query = {
        tags = ["thanos"]
      }
      thanos-receive = {
        tags = ["thanos"]
      }
      thanos-rule = {
        tags = ["thanos"]
      }
      thanos-sidecar = {
        tags = ["thanos"]
      }
      thanos-store = {
        tags = ["thanos"]
      }
    }

    network = {
      bgptools = {
        tags = ["network"]
      }

      bird = {
        tags = ["network"]
      }
      traffic = {
        tags = ["network"]
      }
      weathermap = {
        tags = ["network"]
      }
    }

    postgresql = {
      postgresql-overview = {
        tags = ["postgresql"]
      }
    }

    redis = {
      redis-overview = {
        tags = ["redis"]
      }
    }
  }
}

resource "grafana_folder" "folders" {
  for_each = local.folders

  title = try(each.value.title, each.key)
}

resource "grafana_dashboard" "dashboards" {
  for_each = merge([
    for folder, dashboards in local.dashboards : {
      for name, dashboard in dashboards :
      "${folder}_${name}" => merge(dashboard, {
        folder = folder
        name   = name
        json   = jsondecode(file("${path.root}/dashboards/${folder}/${name}.json"))
      })
    }
  ]...)

  config_json = jsonencode(merge(each.value.json, {
    annotations = {
      list = concat(try(each.value.json["annotations"]["list"], []), [
        {
          enable  = true,
          name    = "Annotations & Alerts"
          type    = "dashboard"
          hide    = false,
          builtIn = 1
          datasource = {
            type = "grafana"
            uid  = "-- Grafana --"
          }
          target = {
            limit    = 100
            matchAny = true
            tags = toset(concat([
              "ansible",
              each.value.folder,
            ], try(each.value.tags, []))),
            type = "tags"
          },
          iconColor = "rgba(0, 211, 255, 1)"
        },
      ])
    }
    editable = false,
    tags = toset(concat([
      each.value.folder,
    ]))
    timezone = "browser",
    uid      = each.key
  }))

  folder = grafana_folder.folders[each.value.folder].id
}
