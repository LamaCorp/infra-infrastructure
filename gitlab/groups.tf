locals {
  groups = {
    documents = {
      name = "Documents"
    }

    infra = {
      name = "Infrastructure"

      subgroups = {
        services = {
          name = "Services"
        }

        tools = {
          name = "Tools"
        }
      }
    }
  }
}
