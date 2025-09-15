terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}


provider "kubernetes" {
  config_path = "${path.module}/kubeconfig"
}

# - name: Fetch kubeconfig from EC2 to Terraform folder
#   ansible.builtin.fetch:
#     src: "/home/ubuntu/.kube/config"
#     dest: "../Terraform/kubeconfig"
#     flat: yes