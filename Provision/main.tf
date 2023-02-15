terraform {
  cloud {
    organization = "nobleadmin"

    workspaces {
      name = "Provisioner"
    }
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# configure key_pair
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCjcbzsSmKqXgvv8AGhPV8Ka/amh1Xkg1PBFfTel3mvDf0FZfNNNuMD0yRJlIdIa8oNDatNEK/WdRxIETVpGDUhpEiH8u7jQU4ZO3x1ZCJvas1Dw2S3f1xz85S0KTMzQa21exBvpzrftXyKEGdAIfFUg4okBRnpwj2BuZSBuz8VjNbaqKvfN0IqNV/OEzHghTHUUEddnsNv2f8+Tfv/Ifa+45GBp5uAIkh9uoJ5xfk0fWc4st4yFSJ5BCNaCF3OimzTXmyyhuUGMQpCsGeCCadsp379jrlfntaRphlZYpN1jsMjAlPv8RCnuzIRSSgHvdASm9mvcWvAlzkDRwJZgzJ6Rv1IwaT7XgC9NHT4ol0Kk6JPJi54W7Dkg8YcYKwAiT0UH+nkfPv+hZ+D4iF6tcmrLqy24tvNcQLnMGMMqTTTu6Z77NHN6ZhGRkAw6dsE/IXdOmAI9NOIgCzGOpo4BnWksgodSgtyNGsnIZwf04B74TsgnZy4T1L9m58I/hSTmRs= Dell@Nobleadmin"
}

data "template_file" "user_data" {
    template =  file("./userdata.yaml")
}
# Configure the AWS Provider
provider "aws" {
  region = "us-east-2"
}

data "aws_vpc" "main" {
    id = "vpc-0c8eab34ea57cfbfe"
}

resource "aws_security_group" "sg_my_main" {
  name        = "sg_my_main"
  description = "my_main_security_group"
  vpc_id      =  data.aws_vpc.main

  ingress = [
    {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
  },

  {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["98.227.15.10/32"]
    ipv6_cidr_blocks = []
  }]

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}


# configure instance
resource "aws_instance" "main" {
  ami           = "ami-0a606d8395a538502"
  instance_type = t2.micro
  key_name = "${aws_key_pair.deployer.key_name}"
  vpc_security_group_ids = [aws_security_group.vpc_security_group_id]
  user_data = data.template_file.user_data.rendered

  tags = {
    "Name" = "myServer"
  }
}

output "public_ip" {
    value = aws_instance.main
}