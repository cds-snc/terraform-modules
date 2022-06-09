terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 4.9"
      configuration_aliases = [aws, aws.us-east-1]
    }
  }
}
