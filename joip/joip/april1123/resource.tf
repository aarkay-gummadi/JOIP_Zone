resource "aws_vpc" "myvpc" {
  cidr_block = var.aws_vpc
}

resource "aws_subnet" "mysubnet" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = var.aws_subnet
}

resource "aws_security_group" "ansible_sg" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
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

resource "aws_instance" "ansible_instance" {
  ami                         = "ami-0fcf52bcf5db7b003"
  subnet_id                   = var.subnet_id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  security_groups             = [aws_security_group.ansible_sg.id]
  key_name                    = "terrformuser"
  tags = {
    Name = "Ansible Server"
  }

  provisioner "local-exec" {
    command = "ansible --version"
  }
}