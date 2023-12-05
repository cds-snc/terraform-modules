terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "tfstate-cds-snc-terraform-modules"
    key            = "tfstate/terraform.tfstate"
    region         = "ca-central-1"
    encrypt        = true
    dynamodb_table = "tfstate-lock"
  }  
}

provider "aws" {
  region              = var.region
  allowed_account_ids = [var.account_id]
}
