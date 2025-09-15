variable "region" {
  default = "us-east-1"
}

variable "cidr" {
  default = "10.0.0.0/16"
}

locals {
  pub_subnet = cidrsubnets(var.cidr,8,0)
  pri_subnet = cidrsubnets(var.cidr,8,0)
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = data.aws_availability_zones.available.names
}

variable "ami" {
  default = "ami-0360c520857e3138f"
}
variable "instance_type" {
 default = "t2.medium" 
}

variable "JS_type" {
 default = "t2.micro" 
}

variable "kubeconfig" {
  type = string
  default = file("${path.module}/kubeconfig.yaml")
}