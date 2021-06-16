/*
Main Terraform template to provision an AWS VPC using this module: https://github.com/terraform-aws-modules/terraform-aws-vpc.

Author: Chad Bartel
Date:   2021-06-15
*/


# Create AWS Terraform provider
provider "aws" {
  region  = local.region
  profile = var.profile

  default_tags {
    tags = merge(
      var.default_tags,
      local.tags
    )
  }
}


# Local variables
locals {
  tags = {
    Terraform = true
    env       = var.environment
    workspace = terraform.workspace
    project   = var.project_name
  }

  # Use conditional expression to load variables (condition ? true_val : false_val)
  region = var.region != null ? var.region : "us-west-2"
  azs             = var.azs != null ? var.azs : ["${local.region}a", "${local.region}b", "${local.region}c"]
  cidr            = var.cidr != null ? var.cidr : "10.0.0.0/16"
  public_subnets  = var.public_subnets != null ? var.public_subnets : ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = var.private_subnets != null ? var.private_subnets : ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}


# Create an AWS VPC using a module
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-aws-vpc"
  cidr = local.cidr

  azs             = local.azs
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets
  
  enable_ipv6 = false

  enable_nat_gateway = true
  enable_vpn_gateway = true
  reuse_nat_ips = true
  one_nat_gateway_per_az = false
  
  public_subnet_tags = {
    subnet-type = "public-subnet"
  }
  
  vpc_tags = {
    Name = "my-aws-vpc"
  }
}