locals {
  repositories = {
    "auth.fsn.lama.tel" = [
      "user_root",
    ]

    "dl.avh.lama.tel" = [
      "qbittorrent",
      "user_root",
    ]

    "dl.psw.lama.tel" = [
      "qbittorrent",
      "user_root",
    ]

    "edge-1.pvl.lama.tel" = [
      "user_root",
    ]

    "edge-2.fra.lama.tel" = [
      "user_root",
    ]

    "games.fsn.lama.tel" = [
      "factorio_2022_zarak",
      "user_root",
    ]

    "gate-1.bar.lama.tel" = [
      "user_root",
    ]

    "gitlab-runner.fsn.lama.tel" = [
      "user_root",
    ]

    "mail.fsn.lama.tel" = [
      "mail",
      "user_root",
    ]

    "nas-1.bar.lama.tel" = [
      "afs",
      "user_root",
    ]

    "nucleus.fsn.lama.tel" = [
      "archives",
      "user_root",
    ]

    "pine.fsn.lama.tel" = [
      "srv",
      "user_root",
    ]

    "postgresql.fsn.lama.tel" = [
      "postgresql",
      "user_root",
    ]

    "redis.fsn.lama.tel" = [
      "redis",
      "user_root",
    ]

    "s3.fsn.lama.tel" = [
      "cloudserver",
      "user_root",
    ]

    "secure-services.fsn.lama.tel" = [
      "acme",
      "user_root",
      "vault",
    ]

    "services.fsn.lama.tel" = [
      "cloudserver",
      "jellyfin",
      "mattermost",
      "matrix",
      "netbox",
      "nextcloud",
      "paperless_risson",
      "pastebin",
      "servarr",
      "static",
      "traefik",
      "user_root",
      "vaultwarden",
      "your_spotify",
    ]
  }

  repositories_computed = merge([
    for machine, repositories in local.repositories : {
      for repository in repositories :
      "${machine}_${repository}" => {
        machine    = machine
        repository = repository
      }
    }
  ]...)
}
