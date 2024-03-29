# PostgreSQL Database cluster with two instances
module "postgresql_cluster" {
  source = "../../"
  name   = "postgresql"

  database_name  = "terratest_postgresql"
  engine         = "aurora-postgresql"
  engine_version = "15.2"
  instances      = 2
  instance_class = "db.t3.medium"
  username       = "thebigcheese"
  password       = "pasword123"

  # These two settings are not recommended for prod, but required by our
  # Terratests so they can properly destroy resources once finished.
  prevent_cluster_deletion = false
  skip_final_snapshot      = true

  backup_retention_period      = 1
  preferred_backup_window      = "01:00-03:00"
  preferred_maintenance_window = "sun:06:00-sun:07:00" # timezone is UTC

  vpc_id     = module.postgresql_cluster_vpc.vpc_id
  subnet_ids = module.postgresql_cluster_vpc.private_subnet_ids

  billing_tag_key   = "Business Unit"
  billing_tag_value = "Terratest"
}

# At least 2 subnets are required by the RDS proxy
module "postgresql_cluster_vpc" {
  source = "../../../vpc/"
  name   = "postgresql-cluster"

  high_availability = true
  enable_flow_log   = false
  block_ssh         = true
  block_rdp         = true
  enable_eip        = false

  billing_tag_key   = "Business Unit"
  billing_tag_value = "Terratest"
}

output "rds_cluster_id" {
  value = module.postgresql_cluster.rds_cluster_id
}

output "vpc_id" {
  value = module.postgresql_cluster_vpc.vpc_id
}

output "private_subnet_ids" {
  value = module.postgresql_cluster_vpc.private_subnet_ids
}
