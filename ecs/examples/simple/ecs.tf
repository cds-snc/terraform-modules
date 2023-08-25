module "ecs" {
 source = "git::https://github.com/cds-snc/terraform-modules.git//ecs?ref=feat/ecs_module"
 
 create_cluster = true
 cluster_name = "cluster_name"

 create_service = true
 name = "service name"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = var.vpc_private_subnet_ids
  }

  depends_on = [
    var.lb_listener,
    var.ecs_task_policy_attachment
  ]

  #load_balancer = {
  #        target_group_arn = var.alb.target_group_arns
  #        container_name   = local.container_name
  #        container_port   = local.container_port
   #   }
 
  create_task_definition = true
  family = "test-task"
  execution_role_arn = var.iam_role_saas_procurement_task_arn
  task_role_arn            = var.iam_role_saas_procurement_task_arn
 
# Container definition(s)
      container_definitions = {

        (local.container_name) = {
          cpu       = 512
          memory    = 1024
          essential = true
          image     = "public.ecr.aws/aws-containers/ecsdemo-frontend:776fd50"
          port_mappings = [
            {
              name          = local.container_name
              containerPort = local.container_port
              hostPort      = local.container_port
              protocol      = "tcp"
            }
          ]

          log_configuration = {
            logDriver = "awsfirelens"
            options = {
              Name                    = "firehose"
              region                  = local.region
              delivery_stream         = "my-stream"
              log-driver-buffer-limit = "2097152"
            }
          }
          memory_reservation = 100
        }
      }
}
