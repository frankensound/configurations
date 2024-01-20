provider "aws" {
    region = local.region
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  cloud {
    organization = "frankensound"
    hostname = "app.terraform.io"

    workspaces {
      name = "aws"
      project = "infrastructure"
    }
  }
}

module "network" {
  source = "./modules/network"

  region = local.region
}

# module "aurora" {
#   source = "./modules/aurora"

#   subnet_ids = module.network.subnet_ids
#   security_group_ids = module.network.security_group_ids
#   master_password = var.master_password
#   db_subnet_group_name = module.network.db_subnet_group_name
# }

module "s3" {
  source = "./modules/s3"
}

module "rabbitmq" {
  source = "./modules/rabbitmq"

  username = var.username
  password = var.password
}


module "postgres" {
  source = "./modules/postgres"

  security_group_ids = module.network.security_group_ids
  master_password = var.master_password
  db_subnet_group_name = module.network.db_subnet_group_name
}