provider "azurerm" {
  features {}
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.75.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.1.0"
    }
  }

  cloud {
    organization = "frankensound"
    hostname = "app.terraform.io"

    workspaces {
      name = "main"
      project = "deployment"
    }
  }
}

module "aks" {
  source = "./modules/aks"

  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  resource_group_id   = module.resource_group.resource_group_id
  env                 = local.env
  aks_name            = local.aks_name
  aks_version         = local.aks_version
  subnet_id           = module.vnet.subnet1_id
}

module "resource_group" {
  source = "./modules/resource_group"

  region = local.region
  resource_group_name = local.resource_group_name
}

module "vnet" {
  source = "./modules/vnet"

  location = module.resource_group.location
  resource_group_name = module.resource_group.name
  env = local.env
}
