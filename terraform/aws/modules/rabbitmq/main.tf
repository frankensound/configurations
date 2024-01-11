resource "aws_mq_broker" "rabbitmq_broker" {
  broker_name     = "broker"
  engine_type     = "RabbitMQ"
  engine_version  = "3.8.6"
  host_instance_type = "mq.t3.micro" 

  user {
    username = var.username
    password = var.password
  }

  apply_immediately = true
  publicly_accessible = true
  deployment_mode = "SINGLE_INSTANCE"

  tags = {
    Name = "MyRabbitMQBroker"
  }
}