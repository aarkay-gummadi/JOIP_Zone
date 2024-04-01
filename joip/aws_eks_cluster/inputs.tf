variable "region" {
  type        = string
  default     = "us-west-2"
  description = "This is for region in oregon"
}

variable "aws_vpc" {
  type        = string
  default     = "192.168.0.0/16"
  description = "This is for vpc in oregon"
}

variable "cidr_block1" {
  type        = string
  default     = "192.168.0.0/24"
  description = "This is for cidr block 1 in oregon"
}

variable "cidr_block2" {
  type        = string
  default     = "192.168.1.0/24"
  description = "This is for cidr block 2 in oregon"
}