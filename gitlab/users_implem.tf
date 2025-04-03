data "gitlab_user" "users" {
  for_each = local.users

  username = each.value
}

resource "gitlab_group_share_group" "lama-corp_owners" {
  for_each       = toset(["roots", "owners"])
  group_id       = gitlab_group.lama-corp.id
  share_group_id = gitlab_group.metas[each.key].id
  group_access   = "owner"
}

# Meta groups to allow for easy access management

resource "gitlab_group" "meta" {
  name                   = "meta"
  path                   = "meta"
  parent_id              = gitlab_group.lama-corp.id
  project_creation_level = "noone"
  visibility_level       = "public"
}

resource "gitlab_group" "metas" {
  for_each = local.meta_groups

  name      = each.key
  path      = each.key
  parent_id = gitlab_group.meta.id

  project_creation_level = "noone"
  visibility_level       = "public"
}

resource "gitlab_group_membership" "metas" {
  for_each = merge(flatten([
    for group, users in local.meta_groups : {
      for user in users :
      "${group}-${user}" => {
        group_id = gitlab_group.metas[group].id
        user_id  = data.gitlab_user.users[user].id
        username = user
      }
    }
  ])...)

  group_id = each.value.group_id
  user_id  = each.value.user_id
  # roots and owners need to be owner as they are owner of the top-level group
  # other users are maintainer so they can at most be given maintainer access
  # to other projects/groups
  access_level = contains(concat(local.meta_groups["roots"], local.meta_groups["owners"]), each.value.username) ? "owner" : "maintainer"
}


# GitHub permissions

data "github_user" "users" {
  for_each = local.users_github

  username = each.value
}

resource "github_membership" "users" {
  for_each = local.users_github

  username = data.github_user.users[each.key].username
  role     = contains(concat(local.meta_groups["roots"], local.meta_groups["owners"]), each.key) ? "admin" : "user"
}
