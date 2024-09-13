terraform {
  backend "s3" {
    bucket         = "jenkins-ha-backend-001"
    key            = "terraform.tfstate"
    dynamodb_table = "jenkins-ha-state-lock"
    region         = "ap-south-1"
    encrypt        = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.2"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}