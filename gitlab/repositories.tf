locals {
  repositories = {
    "48hours" = {
      mirror_to_github = true
      github_path      = "48hours"
    }

    "dictionary" = {
      private = true
    }

    "documents/artwork" = {
      mirror_to_github = true
      github_path      = "documents-artwork"
    }

    "documents/documents" = {
      mirror_to_github = true
      github_path      = "documents-documents"
    }

    "documents/statuts" = {
      mirror_to_github = true
      github_path      = "documents-statuts"
    }

    "graphalama" = {
      description      = "Easy to use widgets for Pygame."
      mirror_to_github = true
      github_path      = "graphalama"
    }

    "infra/authentication" = {
      private = true
    }

    "infra/doc" = {
      description      = "https://doc.lama-corp.space"
      mirror_to_github = true
      github_path      = "infra-doc"
    }

    "infra/infrastructure" = {
      mirror_to_github = true
      github_path      = "infra-infrastructure"
    }

    "infra/services/whoisd" = {
      mirror_to_github = true
      github_path      = "infra-services-whoisd"
    }

    "infra/services/renovate" = {
      allow_pipeline_fail = true
    }

    "lama-corp.space" = {
      mirror_to_github = true
      github_path      = "lama-corp.space"
    }
  }
}
