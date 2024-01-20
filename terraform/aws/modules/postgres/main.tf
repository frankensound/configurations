resource "aws_db_instance" "postgres_free" {
  identifier = "free"
  allocated_storage = 20
  storage_type = "gp2"
  engine = "postgres"
  engine_version = "15.5" 
  instance_class = "db.t3.micro" 
  db_name = "songs"
  username = "postgres"
  password = var.master_password
  parameter_group_name = "default.postgres15"
  db_subnet_group_name = var.db_subnet_group_name
  vpc_security_group_ids = var.security_group_ids
  skip_final_snapshot = true
  publicly_accessible = true
}