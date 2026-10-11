terraform {
  required_version = ">= 1.10.0, < 2.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.13"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Project   = "java-cicd-demo"
      ManagedBy = "Terraform"
    }
  }
}
