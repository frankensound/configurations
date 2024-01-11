variable "master_password" {
  description = "Master password for the Aurora cluster"
  type        = string
}

variable "username" {
  description = "Username for RabbitMQ Broker"
  type        = string
}

variable "password" {
  description = "Password for RabbitMQ Broker"
  type        = string
}