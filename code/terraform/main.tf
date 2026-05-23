terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "main" {
  name     = "rg-elastic-web-prod-ne"
  location = "northeurope"
}

variable "ssh_public_key" {
  description = "SSH public key for VMSS instances."
  type        = string
  default     = ""
}