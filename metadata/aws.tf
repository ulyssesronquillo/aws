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

resource "aws_spot_instance_request" "meta" {
  ami                         = var.ami
  spot_price                  = "0.004"
  wait_for_fulfillment        = "true"
  key_name                    = "servers"
  instance_type               = "t3.micro"
  subnet_id                   = var.subnet
  security_groups             = var.sg
  associate_public_ip_address = "true"
  user_data                   = <<EOF
#!/bin/bash
hostnamectl set-hostname meta
EOF
  tags = {
    Name = "meta"
  }
}

resource "aws_ec2_tag" "tagging" {
  resource_id = aws_spot_instance_request.meta.spot_instance_id
  key         = "Name"
  value       = "meta"
}
