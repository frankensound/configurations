provider "mongodbatlas" {}

terraform {
  required_providers {
    mongodbatlas = {
      source = "mongodb/mongodbatlas"
      version = "1.14.0"
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

resource "mongodbatlas_project" "project" {
  name   = "my-project"
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