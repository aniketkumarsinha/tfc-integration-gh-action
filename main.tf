terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
    }

    random = {
        source = "hashicorp/random"
    }
  }

  cloud {
    organization = "aniketkumarsinha"

    workspaces {
      name = "tfc-integration-with-gh-actions"
    }

}