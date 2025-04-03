resource "gitlab_group" "lama-corp" {
  name = "lama-corp"
  path = "lama-corp"

  description = "Lama Corp."

  project_creation_level = "noone"
  visibility_level       = "public"
}

data "github_organization" "lama-corp" {
  name = "lamacorp"
}
