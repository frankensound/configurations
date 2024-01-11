resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
}

resource "aws_subnet" "subnet1" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "${var.region}a"
}

resource "aws_subnet" "subnet2" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "${var.region}b"
}

resource "aws_security_group" "sg" {
    vpc_id = aws_vpc.main.id

    # Rule for Aurora (PostgreSQL)
    ingress {
        from_port = 5432
        to_port = 5432
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_db_subnet_group" "subnet_group" {
  name = "shared-subnet-group"
  subnet_ids = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
}