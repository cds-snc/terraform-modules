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

run "apply" {
  # Smoke test to validate that the module can successfully be applied
  variables {
    subnet_ids         = run.setup.private_subnet_ids
    security_group_ids = [run.setup.security_group_id]
    task_role_arn      = run.setup.task_role_arn
    task_exec_role_arn = run.setup.task_exec_role_arn
  }
}
