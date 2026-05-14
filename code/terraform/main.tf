# Terraform Provider Configuration
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

# Global Resource Group Definition
resource "azurerm_resource_group" "main" {
  name     = "rg-elastic-web-prod-ne"
  location = "northeurope" # Regional location for all resources
}

variable "ssh_public_key" {
  description = "SSH public key for VMSS instances."
  type        = string
  default     = ""
}