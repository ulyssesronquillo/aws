terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

variable "ami" { type = string }
variable "key-name" { type = string }

provider "aws" {
  profile = "default"
  region  = "us-east-2"
}

resource "aws_vpc" "test-vpc" {
  cidr_block       = "10.0.0.0/21"
  instance_tenancy = "default"
  tags = {
    Name = "test-vpc"
  }
}

# create subnet

resource "aws_subnet" "test-subnet-2a" {
  vpc_id                  = aws_vpc.test-vpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "livestream-10.0.0.0-us-east-2a"
  }
}

# create internet gateway

resource "aws_internet_gateway" "test-igw" {
  vpc_id = aws_vpc.test-vpc.id
  tags = {
    Name = "test-internet-gateway"
  }
}

# create default route to internet

resource "aws_default_route_table" "test-rt" {
  default_route_table_id = aws_vpc.test-vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test-igw.id
  }
  tags = {
    Name = "livestream-route-table"
  }
}

# create web security group

resource "aws_security_group" "test-sg" {
  name        = "test-sg"
  description = "allow ssh and web ports"
  vpc_id      = aws_vpc.test-vpc.id

  ingress {
    description = "ping"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "ALL"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "test-sg"
  }
}

resource "aws_spot_instance_request" "test" {
  ami                         = var.ami
  spot_price                  = "0.0040"
  wait_for_fulfillment        = "true"
  key_name                    = var.key-name
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.test-subnet-2a.id
  security_groups             = [aws_security_group.test-sg.id]
  associate_public_ip_address = "true"
  user_data                   = <<EOF
#!/bin/bash
hostnamectl set-hostname test
amazon-linux-extras install nginx1
systemctl start nginx
systemctl enable nginx
sleep 10
echo "web1" > /usr/share/nginx/html/index.html
EOF
  tags = {
    Name = "test"
  }
}
