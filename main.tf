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
}

provider "azurerm" {
  features {
    
  }
}

resource "azurerm_resource_group" "rg" {
  name = "azure-tfc"
  location = "centralindia"
}