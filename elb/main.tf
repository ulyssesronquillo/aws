terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

variable "ami" {
  type        = string
  description = "ami image"
}

# create a vpc

resource "aws_vpc" "web-vpc" {
  cidr_block       = "10.0.0.0/21"
  instance_tenancy = "default"
  tags = {
    Name = "web"
  }
}

# create 4 subnets

resource "aws_subnet" "web-subnet-2a" {
  vpc_id                  = aws_vpc.web-vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "web-10.0.0.0-us-east-1a"
  }
}

resource "aws_subnet" "web-subnet-2b" {
  vpc_id                  = aws_vpc.web-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "web-10.0.1.0-us-east-2a"
  }
}

resource "aws_subnet" "web-subnet-2c" {
  vpc_id                  = aws_vpc.web-vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = true
  tags = {
    Name = "web-10.0.2.0-us-east-1c"
  }
}

resource "aws_subnet" "web-subnet-2d" {
  vpc_id                  = aws_vpc.web-vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1d"
  map_public_ip_on_launch = true
  tags = {
    Name = "web-10.0.3.0-us-east-1d"
  }
}

# create internet gateway

resource "aws_internet_gateway" "web-igw" {
  vpc_id = aws_vpc.web-vpc.id
  tags = {
    Name = "web-igw"
  }
}

# create default route to internet

resource "aws_default_route_table" "web-rt" {
  default_route_table_id = aws_vpc.web-vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.web-igw.id
  }
  tags = {
    Name = "web-rt"
  }
}

# create load balancer

resource "aws_lb" "web-lb" {
  name               = "web-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web-server-sg.id]
  subnets            = [aws_subnet.web-subnet-2a.id, aws_subnet.web-subnet-2b.id, aws_subnet.web-subnet-2c.id]
  enable_http2       = false
  tags = {
    Name = "web-lb"
  }
}

# create target group

resource "aws_lb_target_group" "web-tg" {
  name     = "web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.web-vpc.id
  health_check {
    interval            = 30
    path                = "/index.html"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

# create listener

resource "aws_lb_listener" "web-listener" {
  load_balancer_arn = aws_lb.web-lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-tg.arn
  }
}

resource "aws_lb_target_group_attachment" "web-attachment1" {
  target_group_arn = aws_lb_target_group.web-tg.arn
  target_id        = aws_instance.web1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "web-attachment2" {
  target_group_arn = aws_lb_target_group.web-tg.arn
  target_id        = aws_instance.web2.id
  port             = 80
}

# create web security group

resource "aws_security_group" "web-server-sg" {
  name        = "web-server-sg"
  description = "allow ssh and web ports"
  vpc_id      = aws_vpc.web-vpc.id

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
    Name = "livestream-web-server-sg"
  }
}

# create instance

resource "aws_instance" "web1" {
  ami                         = var.ami
  key_name                    = "servers"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.web-subnet-2a.id
  security_groups             = [aws_security_group.web-server-sg.id]
  associate_public_ip_address = "true"
  user_data                   = file("web1.sh")
  tags = {
    Name = "web1"
  }
}

resource "aws_instance" "web2" {
  ami                         = var.ami
  key_name                    = "servers"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.web-subnet-2b.id
  security_groups             = [aws_security_group.web-server-sg.id]
  associate_public_ip_address = "true"
  user_data                   = file("web2.sh")
  tags = {
    Name = "web2"
  }
}
