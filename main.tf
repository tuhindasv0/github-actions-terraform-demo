terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.26.0"
    }

  }
  required_version = "~> 1.0"

  backend "remote" {
    organization = "tuhindasv0"

    workspaces {
      name = "github-actions-terraform-demo"
    }
  }
}


provider "aws" {
  region = "us-east-1"
}


resource "aws_instance" "web" {
  ami                    = "ami-09e67e426f25ce0d7"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web-sg.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF
}

resource "aws_security_group" "web-sg" {
  name        = "${terraform.workspace}-sg"
  description = "Allow TCP/22"
  ingress {
    description = "Allow 22 from our public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${terraform.workspace}-securitygroup"
  }
}

output "web-address" {
  value = "${aws_instance.web.public_dns}:8080"
}