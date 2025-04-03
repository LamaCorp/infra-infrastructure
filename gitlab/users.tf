locals {
  # Lama Corp. username -> GitLab username association
  users = {
    "diego"     = "ddorn"
    "matteo"    = "mtdoudin"
    "michael"   = "michaelpaper"
    "risson"    = "risson"
    "theotypus" = "Theotypus"
  }

  # Lama Corp. username -> GitHub username association
  users_github = {
    "diego"  = "ddorn"
    "risson" = "rissson"
  }

  meta_groups = {
    roots = [
      "diego",
      "risson",
    ]
    owners = [
      "diego",
      "risson",
    ]

    lamas = [
      "diego",
      "matteo",
      "michael",
      "risson",
      "theotypus",
    ]

    users = keys(local.users)
  }
}
