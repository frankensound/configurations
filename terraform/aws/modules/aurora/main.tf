resource "aws_rds_cluster_parameter_group" "pgroup-default" {
  name   = "rds-pgroup"
  family = "aurora-postgresql15"

  parameter {
    name  = "log_connections"
    value = "1"
  }
}

resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier = "cluster"
  engine = "aurora-postgresql"
  engine_mode = "provisioned"
  database_name = "songs"
  master_username = "postgres"
  master_password = var.master_password

  vpc_security_group_ids = var.security_group_ids
  db_subnet_group_name = var.db_subnet_group_name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.pgroup-default.name

  skip_final_snapshot = true
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  # Initial number of replicas
  count = 1
  cluster_identifier = aws_rds_cluster.aurora_cluster.id
  instance_class     = "db.t3.medium"
  engine             = aws_rds_cluster.aurora_cluster.engine
  engine_version     = aws_rds_cluster.aurora_cluster.engine_version
  identifier = "instance-${count.index}"
}

resource "aws_appautoscaling_target" "aurora_autoscaling_target" {
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = "cluster:${aws_rds_cluster.aurora_cluster.id}"
  scalable_dimension = "rds:cluster:ReadReplicaCount"
  service_namespace  = "rds"
}

resource "aws_appautoscaling_policy" "aurora_autoscaling_policy" {
  name               = "AuroraAutoScalingPolicy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.aurora_autoscaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.aurora_autoscaling_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.aurora_autoscaling_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "RDSReaderAverageCPUUtilization"
    }

    # Adjustable
    target_value = 70.0
  }
}