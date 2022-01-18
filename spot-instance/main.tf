terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

variable "ami" { type = string }
variable "subnet" { type = string }
variable "sg" { type = list(any) }

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_spot_instance_request" "test" {
  ami                         = var.ami
  spot_price                  = "0.0037"
  wait_for_fulfillment        = "true"
  key_name                    = "servers"
  instance_type               = "t3.micro"
  subnet_id                   = var.subnet
  security_groups             = var.sg
  associate_public_ip_address = "true"
  user_data                   = <<-EOF
              #!/bin/bash
              hostnamectl set-hostname test
              EOF
  tags = {
    Name = "test"
  }
}

resource "aws_ec2_tag" "tagging" {
  resource_id = aws_spot_instance_request.test.spot_instance_id
  key         = "Name"
  value       = "test"
}
