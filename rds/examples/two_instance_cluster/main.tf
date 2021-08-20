# Database cluster with two instances
module "two_instance_cluster" {
  source = "../../"
  name   = "two-instance-cluster"

  database_name  = "terratest"
  engine_version = "11.9"
  instances      = 2
  instance_class = "db.t3.medium"
  username       = "thebigcheese"
  password       = "pasword123"

  # This is not recommended for prod, but required by our
  # Terratests so they can cleanup after themselves
  prevent_cluster_deletion = false

  backup_retention_period = 1
  preferred_backup_window = "01:00-03:00"

  vpc_id     = module.rds_cluster_vpc.vpc_id
  subnet_ids = module.rds_cluster_vpc.private_subnet_ids

  billing_tag_key   = "Business Unit"
  billing_tag_value = "Terratest"
}

# At least 2 subnets are required by the RDS proxy
module "rds_cluster_vpc" {
  source = "../../../vpc/"
  name   = "rds-cluster-vpc"

  high_availability = true
  enable_flow_log   = false
  block_ssh         = true
  block_rdp         = true

  billing_tag_key   = "Business Unit"
  billing_tag_value = "Terratest"
}
