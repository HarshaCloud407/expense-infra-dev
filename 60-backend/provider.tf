terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.84.0"
    }

    null = {
      source  = "hashicorp/null"
      version = ">= 3.0.0"
    }
  }

  backend "s3" {
    bucket         = "82s-tf-remote-state-dev-hyd"
    key            = "expense-dev-backend"
    region         = "us-east-1"
    dynamodb_table = "82s-tf-remote-state-dev-hyd"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project     = "expense"
      Environment = "dev"
      Terraform   = "true"
    }
  }
}