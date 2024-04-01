variable "region" {
  type    = string
  default = "us-west-2"
}

variable "aws_vpc" {
  type    = string
  default = "192.168.0.0/16"
}

variable "aws_subnet" {
  type    = string
  default = "192.168.0.0/24"
}

variable "subnet_id" {
  type = string
  default = "subnet-0d72010037458f2d1"
}