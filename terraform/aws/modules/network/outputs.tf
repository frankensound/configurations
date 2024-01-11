output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_ids" {
  value = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
}

output "security_group_ids" {
  value = [aws_security_group.sg.id]
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.subnet_group.name
}