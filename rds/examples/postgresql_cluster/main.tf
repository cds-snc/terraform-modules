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

  enable_flow_log                  = true
  availability_zones               = 2
  cidrsubnet_newbits               = 8
  single_nat_gateway               = true
  allow_https_request_out          = true
  allow_https_request_out_response = true
  allow_https_request_in           = true
  allow_https_request_in_response  = true

  billing_tag_key   = "Business Unit"
  billing_tag_value = "Terratest"
}
