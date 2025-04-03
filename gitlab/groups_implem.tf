resource "gitlab_group" "groups_level_1" {
  for_each = {
    for path, group in local.groups :
    path => merge(group, {
      path = path
    })
  }

  path      = each.value.path
  parent_id = gitlab_group.lama-corp.id

  name = lookup(each.value, "name", each.value.path)

  project_creation_level = "maintainer"
  visibility_level       = lookup(each.value, "private", false) ? "private" : "public"
}

resource "gitlab_group" "groups_level_2" {
  for_each = merge(flatten([
    for group_1_path, group_1 in local.groups : [
      for group_2_path, group_2 in lookup(group_1, "subgroups", {}) : {
        "${group_1_path}/${group_2_path}" = merge(group_2, {
          path         = group_2_path
          group_1_path = group_1_path
        })
      }
    ]
  ])...)

  path      = each.value.path
  parent_id = gitlab_group.groups_level_1[each.value.group_1_path].id

  name = lookup(each.value, "name", each.value.path)

  project_creation_level = "maintainer"
  visibility_level       = lookup(each.value, "private", false) ? "private" : "public"
}

resource "gitlab_group" "groups_level_3" {
  for_each = merge(flatten([
    for group_1_path, group_1 in local.groups : [
      for group_2_path, group_2 in lookup(group_1, "subgroups", {}) : [
        for group_3_path, group_3 in lookup(group_2, "subgroups", {}) : {
          "${group_1_path}/${group_2_path}/${group_3_path}" = merge(group_3, {
            path         = group_3_path
            group_2_path = group_2_path
            group_1_path = group_1_path
          })
        }
      ]
    ]
  ])...)

  path      = each.value.path
  parent_id = gitlab_group.groups_level_2["${each.value.group_1_path}/${each.value.group_2_path}"].id

  name = lookup(each.value, "name", each.value.path)

  project_creation_level = "maintainer"
  visibility_level       = lookup(each.value, "private", false) ? "private" : "public"
}

locals {
  groups_computed = merge(gitlab_group.groups_level_1, gitlab_group.groups_level_2, gitlab_group.groups_level_3)
}
