# Basic setup for DocumentDB

provider "aws" {
  region = "ca-central-1"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main-vpc"
  }
}

# Create Private Subnets
resource "aws_subnet" "private_subnets" {
  count = 2 # Creates two private subnets

  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(["10.0.1.0/24", "10.0.2.0/24"], count.index)
  availability_zone       = element(["ca-central-1a", "ca-central-1b"], count.index)
  map_public_ip_on_launch = false

  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
}

# Instance of DocumentDB
module "test_documentdb" {
  source              = "../../"
  enable              = true
  billing_code        = "billing_code_test"
  subnet_ids          = aws_subnet.private_subnets[*].id
  database_name       = "test-db"
  master_username     = "test"
  master_password     = "another_test"
  instance_class      = "db.t3.medium"
  cluster_size        = "1"
  deletion_protection = true
}