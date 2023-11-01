module "simple" {
  source = "../.."

  cloudwatch_alarm_arns = [
    "arn:aws:cloudwatch:ca-central-1:123456789012:alarm:my-alarm",
  ]
  ecs_service_arns = [
    "arn:aws:ecs:ca-central-1:123456789012:service/my-cluster/my-service",
    "arn:aws:ecs:ca-central-1:123456789012:service/my-cluster/other-service",
  ]
  rds_cluster_arns = [
    "arn:aws:rds:ca-central-1:123456789012:cluster:my-cluster",
  ]
  route53_healthcheck_arns = [
    "arn:aws:route53:::healthcheck/my-healthcheck",
  ]

  schedule_shutdown = "cron(0 22 * * ? *)"       # 10pm UTC, every day
  schedule_startup  = "cron(0 12 ? * MON-FRI *)" # 12pm UTC, Monday-Friday

  billing_tag_value = "simple"
}