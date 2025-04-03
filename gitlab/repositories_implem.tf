resource "gitlab_project" "projects" {
  for_each = {
    for path, repository in local.repositories :
    path => merge(repository, {
      full_path = path
      # convert `path/to/repo` to `repo`
      path = split("/", path)[length(split("/", path)) - 1]
      # convert `path/to/repo` to `path/to`
      group_path = join("/", slice(split("/", path), 0, length(split("/", path)) - 1))
    })
  }

  name        = lookup(each.value, "name", each.value.path)
  description = "${lookup(each.value, "description", "")}\n${lookup(each.value, "website", "")}"
  topics      = lookup(each.value, "topics", [])
  path        = each.value.path

  namespace_id = parseint(strcontains(each.value.full_path, "/") ? local.groups_computed[each.value.group_path].id : gitlab_group.lama-corp.id, 10)

  visibility_level   = lookup(each.value, "private", false) ? "private" : "public"
  pages_access_level = lookup(each.value, "private", false) ? "private" : "public"

  merge_method                                     = "ff"
  allow_merge_on_skipped_pipeline                  = true
  only_allow_merge_if_all_discussions_are_resolved = true
  only_allow_merge_if_pipeline_succeeds            = !lookup(each.value, "allow_pipeline_fail", false)
  remove_source_branch_after_merge                 = true
  squash_option                                    = "default_on"

  merge_commit_template = <<-EOS
  Merge branch '%%{source_branch}' into '%%{target_branch}'

  %%{title}

  %%{issues}

  See merge request %%{reference}
  EOS

  squash_commit_template = <<-EOS
  %%{title}

  Squashed commit of the following:

  %%{all_commits}
  EOS

  auto_devops_enabled    = false
  shared_runners_enabled = false

  # deleting repositories should be manual
  archive_on_destroy = true

  # See https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/project
  provisioner "local-exec" {
    command = "curl --request DELETE --header 'PRIVATE-TOKEN: ${var.gitlab_token}' '${var.gitlab_base_url}/projects/${self.id}/protected_branches/${self.default_branch}'"
  }

  lifecycle {
    ignore_changes = [
      import_url,
    ]
  }
}


# Users

resource "gitlab_project_share_group" "projects" {
  for_each = merge(flatten([
    for access_level in ["maintainer", "developer"] : [
      for path, repository in local.repositories : {
        # give developer access to users by default
        for group in lookup(repository, "${access_level}_groups", access_level == "developer" ? ["users"] : []) :
        "${path}_${access_level}_${group}" => {
          path         = path
          group        = group
          group_access = access_level
        }
      }
    ]
  ])...)

  project      = gitlab_project.projects[each.value.path].id
  group_id     = gitlab_group.metas[each.value.group].id
  group_access = each.value.group_access
}


# Branch protection and MR approvals

resource "gitlab_branch_protection" "projects_default_branch" {
  for_each = local.repositories

  project                = gitlab_project.projects[each.key].id
  branch                 = gitlab_project.projects[each.key].default_branch
  push_access_level      = lookup(each.value, "allow_default_branch_push", false) ? "maintainer" : "no one"
  merge_access_level     = "maintainer"
  unprotect_access_level = "maintainer"
  allow_force_push       = false
}

resource "gitlab_project_level_mr_approvals" "projects" {
  for_each = local.repositories

  project = gitlab_project.projects[each.key].id

  disable_overriding_approvers_per_merge_request = true

  merge_requests_author_approval             = true
  merge_requests_disable_committers_approval = false
}

/*resource "gitlab_project_approval_rule" "projects" {
  for_each           = local.repositories
  name               = "default"
  project            = gitlab_project.projects[each.key].id
  approvals_required = 1
}*/


# GitHub mirroring

resource "github_repository" "projects" {
  for_each = {
    for path, repository in local.repositories :
    path => repository if lookup(repository, "mirror_to_github", false)
  }

  name         = each.value.github_path
  description  = lookup(each.value, "description", "")
  topics       = lookup(each.value, "topics", [])
  homepage_url = gitlab_project.projects[each.key].web_url
  visibility   = "public"

  archive_on_destroy = false

  has_issues           = true
  has_projects         = false
  has_wiki             = false
  has_downloads        = false
  is_template          = false
  vulnerability_alerts = false

  allow_auto_merge       = false
  allow_merge_commit     = false
  allow_rebase_merge     = true
  allow_squash_merge     = false
  auto_init              = false
  delete_branch_on_merge = true
}

resource "gitlab_project_mirror" "projects" {
  for_each = {
    for path, repository in local.repositories :
    path => repository if lookup(repository, "mirror_to_github", false)
  }

  project                 = gitlab_project.projects[each.key].id
  url                     = "https://lamacorp-bot:${var.github_mirroring_token}@github.com/lamacorp/${each.value.github_path}.git"
  only_protected_branches = true
}
