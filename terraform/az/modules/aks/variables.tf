variable "location" {
  description = "The location for the AKS resources"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "resource_group_id" {
  description = "The ID of the resource group"
  type        = string
}

variable "env" {
  description = "The environment (e.g., dev, prod)"
  type        = string
}

variable "aks_name" {
  description = "The name of the AKS cluster"
  type        = string
}

variable "aks_version" {
  description = "The version of the AKS cluster"
  type        = string
}

variable "subnet_id" {
  description = "The subnet ID for the AKS cluster"
  type        = string
}