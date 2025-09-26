variable "region" {
  default = "us-east-1"
}

variable "cidr" {
  default = "10.0.0.0/16"
}

locals {
  pub_subnet1 = "10.0.1.0/24"
  pub_subnet2 = "10.0.2.0/24"
  # pub_subnet3 = "10.0.3.0/24"
  pri_subnet1 = "10.0.4.0/24"
  pri_subnet2 = "10.0.5.0/24"
  # pri_subnet3 = "10.0.6.0/24"
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = data.aws_availability_zones.available.names
}

locals {
  secrets = yamldecode(file("${path.module}/variables.yaml"))
}

variable "ami" {
  default = "ami-0360c520857e3138f"
}
variable "instance_type" {
 default = "t2.medium" 
}
