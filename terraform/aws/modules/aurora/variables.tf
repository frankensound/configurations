variable "subnet_ids" {
  description = "Subnet IDs for the Aurora cluster"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs for the Aurora cluster"
  type        = list(string)
}

variable "master_password" {
  description = "Master password for the Aurora cluster"
  type        = string
}

variable "db_subnet_group_name" {
  description = "The DB subnet group name to use for the Aurora cluster"
  type        = string
}