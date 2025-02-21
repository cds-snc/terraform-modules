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
# Security Group for DocumentDB
resource "aws_security_group" "docdb_sg" {
  vpc_id = aws_vpc.main.id
  name   = "secured-docdb-sg"

  tags = {
    Name = "docdb-security-group"
  }
}
# Allow inbound traffic to DocumentDB from within the VPC
resource "aws_security_group_rule" "docdb_ingress" {
  type              = "ingress"
  from_port         = 27017
  to_port           = 27017
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/16"] # Only allow traffic from the VPC
  security_group_id = aws_security_group.docdb_sg.id
}

# Allow all outbound traffic
resource "aws_security_group_rule" "docdb_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.docdb_sg.id
}

# Create a KMS key for encryption
resource "aws_kms_key" "docdb_kms" {
  description             = "KMS key for DocumentDB encryption"
  enable_key_rotation     = true
  deletion_window_in_days = 30
}

# Create an alias for the KMS key
resource "aws_kms_alias" "docdb_kms_alias" {
  name          = "alias/docdb-key"
  target_key_id = aws_kms_key.docdb_kms.id
}
module "test_secured_documentdb" {
  source                 = "./../"
  enable                 = true
  database_name          = "secureddocumentdb"
  billing_code           = "billing_code_test"
  master_username        = "test"
  master_password        = "another_test"
  subnet_ids             = aws_subnet.private_subnets[*].id
  vpc_security_group_ids = [aws_security_group.docdb_sg.id]
  storage_encrypted      = true
  kms_key_id             = aws_kms_key.docdb_kms.id
  instance_class         = "db.t3.medium"
  cluster_family         = "docdb5.0"
  cluster_size           = "1"
  deletion_protection    = true
  backup_window          = "07:00-07:30"
  parameters = [
    {
      apply_method = "immediate"
      name         = "tls"
      value        = "enabled"
    }
  ]
}