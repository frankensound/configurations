output "rabbitmq_broker_amqp_endpoint" {
  value = aws_mq_broker.rabbitmq_broker.instances[0].endpoints[0]
}

output "rabbitmq_broker_console_endpoint" {
  value = aws_mq_broker.rabbitmq_broker.instances[0].console_url
}