provider "mongodbatlas" {}

provider "aws" {
  region = local.region
}

terraform {
  required_providers {
    mongodbatlas = {
      source = "mongodb/mongodbatlas"
      version = "1.14.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  cloud {
    organization = "frankensound"
    hostname = "app.terraform.io"

    workspaces {
      name = "atlas"
      project = "infrastructure"
    }
  }
}

resource "mongodbatlas_project" "project" {
  name   = "frankensound"
  org_id = var.mongodb_org_id
}

resource "mongodbatlas_cluster" "my_cluster" {
  project_id              =  mongodbatlas_project.project.id
  name                    = "myCluster"

  provider_name           = "TENANT"
  backing_provider_name   = "AWS"
  provider_region_name    = "EU_WEST_3"
  provider_instance_size_name = "M0"
}

resource "mongodbatlas_project_ip_access_list" "whitelist" {
  project_id = mongodbatlas_project.project.id
  cidr_block = "0.0.0.0/0"  # Allow all IP addresses
  comment    = "Allow access from anywhere"
}

resource "mongodbatlas_database_user" "mongo_db_user" {
  username           = var.username
  password           = var.username
  project_id         = mongodbatlas_project.project.id
  auth_database_name = "admin"

  roles {
    role_name     = "readWrite"
    database_name = "profiles"
  }
}