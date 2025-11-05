variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "galaxy-store"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.0.0.0/24","10.0.1.0/24"]
}

variable "private_subnets" {
  type    = list(string)
  default = ["10.0.10.0/24","10.0.11.0/24"]
}

variable "eks_node_instance_type" {
  type    = string
  default = "t3.medium"
}

variable "eks_node_desired" {
  type    = number
  default = 2
}
