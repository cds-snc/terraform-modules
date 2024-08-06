provider "aws" {
  region = "ca-central-1"
}

variables {
  cluster_name    = "simple_cluster"
  service_name    = "nginx"
  task_cpu        = 256
  task_memory     = 512
  container_image = "nginx:latest"
  desired_count   = 1

  enable_autoscaling       = true
  autoscaling_min_capacity = 1
  autoscaling_max_capacity = 2
}

run "setup" {
  module {
    source = "./tests/setup"
  }
}

run "plan" {
  command = plan

  variables {
    subnet_ids          = ["subnet-12345678"]
    security_group_ids  = ["sg-12345678"]
    container_host_port = 8080
    lb_target_group_arn = "arn:aws:elasticloadbalancing:ca-central-1:123456789012:targetgroup/tg1/1234567890"
    lb_target_group_arns = [{
      target_group_arn = "arn:aws:elasticloadbalancing:ca-central-1:123456789012:targetgroup/tg2/1234567890"
      container_name   = "nginx-proxy"
      container_port   = 8081
    }]
  }

  assert {
    condition     = length(aws_ecs_service.this.load_balancer) == 2
    error_message = "Unexpected load_balancer length"
  }

  assert {
    condition     = [for lb in aws_ecs_service.this.load_balancer : lb][0].target_group_arn == "arn:aws:elasticloadbalancing:ca-central-1:123456789012:targetgroup/tg1/1234567890"
    error_message = "Unexpected target_group_arn value"
  }

  assert {
    condition     = [for lb in aws_ecs_service.this.load_balancer : lb][0].container_name == "nginx"
    error_message = "Unexpected container_name value"
  }

  assert {
    condition     = [for lb in aws_ecs_service.this.load_balancer : lb][0].container_port == 8080
    error_message = "Unexpected container_port value"
  }

  assert {
    condition     = [for lb in aws_ecs_service.this.load_balancer : lb][1].target_group_arn == "arn:aws:elasticloadbalancing:ca-central-1:123456789012:targetgroup/tg2/1234567890"
    error_message = "Unexpected target_group_arn value"
  }

  assert {
    condition     = [for lb in aws_ecs_service.this.load_balancer : lb][1].container_name == "nginx-proxy"
    error_message = "Unexpected container_name value"
  }

  assert {
    condition     = [for lb in aws_ecs_service.this.load_balancer : lb][1].container_port == 8081
    error_message = "Unexpected container_port value"
  }
}

run "apply" {
  # Smoke test to validate that the module can successfully be applied
  variables {
    subnet_ids         = run.setup.private_subnet_ids
    security_group_ids = [run.setup.security_group_id]
    task_role_arn      = run.setup.task_role_arn
    task_exec_role_arn = run.setup.task_exec_role_arn
  }
}
