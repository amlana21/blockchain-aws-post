terraform {
  required_version = ">= 1.2.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.11.0"
    }

    tls = {
      source = "hashicorp/tls"
      version = "4.0.4"
    }
  } 

}

provider "aws" {
  region = "us-east-1"
}


module "networking" {
    source = "./networking"
}


module "instance" {
    source = "./instance"
    subnet_id = module.networking.app_subnet_id
    security_group_id = module.networking.security_group_id
}