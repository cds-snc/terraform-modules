module "async_stream" {
  source = "../../"

  rds_stream_name = "async-stream"
  rds_cluster_arn = module.database.rds_cluster_arn

  billing_tag_value = "TerraformModules"
}

#
# Network
#
module "vpc" {
  source = "github.com/cds-snc/terraform-modules//vpc?ref=v9.6.8"
  name   = "async-stream"

  enable_flow_log                  = true
  availability_zones               = 2
  cidrsubnet_newbits               = 8
  single_nat_gateway               = true
  allow_https_request_out          = true
  allow_https_request_out_response = true
  allow_https_request_in           = true
  allow_https_request_in_response  = true

  billing_tag_value = "TerraformModules"
}

#
# Database
#
module "database" {
  source = "github.com/cds-snc/terraform-modules//rds?ref=v9.6.8"
  name   = "async-stream"

  database_name  = "test"
  engine         = "aurora-postgresql"
  engine_version = "15.2"
  instances      = 2
  instance_class = "db.r6g.large" # https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/DBActivityStreams.Overview.html#DBActivityStreams.Overview.requirements.classes
  username       = "thisshouldprobablybesecret"
  password       = "thisshouldmostdefinitelybesecret"

  backup_retention_period             = 7
  preferred_backup_window             = "02:00-04:00"
  performance_insights_enabled        = false
  iam_database_authentication_enabled = true
  upgrade_immediately                 = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  billing_tag_value = "TerraformModules"
}