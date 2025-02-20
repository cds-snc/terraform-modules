# A more secure example of a DocumentDB setup
module "test_secured_documentdb" {
  source                 = "../../"
  enable                 = true
  database_name          = "secured_documentdb"
  billing_code           = "billing_code_test"
  master_username        = "test"
  master_password        = "another_test"
  subnet_ids             = module.subnets.private_subnet_id
  vpc_security_group_ids = [module.security_group-documentdb.security_group_ids]
  storage_encrypted      = true
  kms_key_id             = module.kms_key.key_arn
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