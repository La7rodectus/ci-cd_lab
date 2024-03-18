provider "aws" {
  region     = "us-east-2"
  profile    = "ci-test"
}

terraform {
  cloud {
    organization = "La7rodectus"
    workspaces {
      tags = ["ci-test-lab"]
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.52.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
  }
  required_version = ">= 1.1.0"
}

resource "aws_instance" "web_server" {
  ami           = "ami-05fb0b8c1424f266b"
  instance_type = "t2.micro"
  key_name      = "test-connect"
  vpc_security_group_ids = [aws_security_group.web_server_sg.id]
  associate_public_ip_address = true
  tags = {
    Name = "test-connect"
  }
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "web_server_sg" {
  name        = "web-server-sg-tf"
  description = "Allow HTTPS to web server"
  vpc_id      = data.aws_vpc.default.id
  tags = {
    Name = "test-connect"
  }
}

resource "aws_security_group_rule" "allow_https" {
  type              = "ingress"
  description       = "HTTPS ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_server_sg.id
}

resource "aws_security_group_rule" "allow_all" {
  type              = "ingress"
  description       = "allow all"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_server_sg.id 
}


resource "aws_security_group_rule" "allow_ssh_from_vpc" {
  type              = "ingress"
  description       = "Allow SSH from VPC"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.default.cidr_block]
  security_group_id = aws_security_group.web_server_sg.id
}
