locals {
  labels = {
    bug = {
      color = "#ff0000"
    }
    documentation = {
      color = "#6699cc"
    }
    duplicate = {
      color = "#909090"
    }
    enhancement = {
      color = "#8fbc8f"
    }
    "external contribution" = {
      color = "#3cb371"
    }
    "good first issue" = {
      color = "#00b140"
    }
    "help wanted" = {
      color = "#00b140"
    }
    invalid = {
      color = "#eee600"
    }
    "priority::0" = {
      color       = "#9400d3"
      description = "Very urgent"
    }
    "priority::1" = {
      color       = "#ff0000"
      description = "Important"
    }
    "priority::2" = {
      color       = "#ed9121"
      description = "Nice to have but not that important"
    }
    question = {
      color = "#9400d3"
    }
    "scope::backend" = {
      color = "#b042f5"
    }
    "scope::content" = {
      color       = "#6642f5"
      description = "Not related to base code, content addition"
    }
    "scope::frontend" = {
      color = "#cc338b"
    }
    security = {
      color = "#ff0000"
    }
    "won't fix" = {
      color = "#36454f"
    }
  }
}

resource "gitlab_group_label" "lama_corp_labels" {
  for_each = local.labels

  group       = try(local.groups_computed[each.value.group].id, gitlab_group.lama-corp.id)
  name        = each.key
  color       = each.value.color
  description = lookup(each.value, "description", "")
}
