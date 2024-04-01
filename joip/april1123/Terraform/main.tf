terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

data "aws_region" "current" {
  name = "us-west-2"
}

resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
}

resource "aws_subnet" "mysubnet" {
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = aws_vpc.myvpc.cidr_block
  availability_zone = "${data.aws_region.current.name}a"
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "route_table_association" {
  subnet_id      = aws_subnet.mysubnet.id
  route_table_id = aws_route_table.rt.id
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP traffic"
  vpc_id      = aws_vpc.myvpc.id
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH traffic"
  vpc_id      = aws_vpc.myvpc.id
  ingress {
    description = "SSHC"
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
}

resource "aws_instance" "ansible" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  key_name                    = "terrformuser"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.mysubnet.id
  vpc_security_group_ids      = [aws_security_group.allow_http.id, aws_security_group.allow_ssh.id]

  tags = {
    Name = "ansible"
  }

  user_data = file("ansible.sh")

  #   provisioner "local-exec" {
  #     command = "ansible --version"
  #   }

}

resource "null_resource" "test" {
  provisioner "local-exec" {
    command = "ansible --version"
  }
}

resource "null_resource" "test1" {
  provisioner "local-exec" {
    command = "touch {1..10}"
  }
}