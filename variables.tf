locals {
  subnets = length(data.aws_availability_zones.available.names)
}

variable "project" {
  default = "prod"
}

variable "enable_nat_gateway" {
  type = bool
  default = true
}

variable "environment" {}
variable "vpc_cidr" {}
