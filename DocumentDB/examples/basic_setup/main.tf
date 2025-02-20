# Basic setup for DocumentDB

module "test_documentdb" {
  source              = "../../"
  enable              = true
  billing_code        = "billing_code_test"
  subnet_ids          = module.subnets.private_subnet_id
  database_name       = "test-db"
  master_username     = "test"
  master_password     = "another_test"
  instance_class      = "db.t3.medium"
  cluster_size        = "1"
  deletion_protection = true
}