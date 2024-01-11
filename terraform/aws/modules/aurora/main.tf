resource "aws_rds_cluster" "aurora_cluster" {
    cluster_identifier = "aurora-cluster"
    engine = "aurora-postgresql"
    engine_mode = "provisioned"
    database_name = "songs"
    master_username = "postgres"
    master_password = var.master_password
    skip_final_snapshot = true
    vpc_security_group_ids = var.security_group_ids
    db_subnet_group_name = var.db_subnet_group_name

    backup_retention_period = 7

  serverlessv2_scaling_configuration {
    max_capacity = 12
    min_capacity = 2
  }
}