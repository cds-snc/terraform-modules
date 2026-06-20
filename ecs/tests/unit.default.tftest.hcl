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
    container_definitions = [
      jsonencode({
        name      = "init"
        image     = "nginx:latest"
        essential = false
      }),
      jsonencode({
        name      = "test"
        image     = "nginx:latest"
        essential = false
        cpu       = 128
        memory    = 256
      })
    ]
    container_depends_on = [{
      containerName = "init"
      condition     = "SUCCESS"
    }]
    lb_target_group_arn = "arn:aws:elasticloadbalancing:ca-central-1:123456789012:targetgroup/tg1/1234567890"
    lb_target_group_arns = [{
      target_group_arn = "arn:aws:elasticloadbalancing:ca-central-1:123456789012:targetgroup/tg2/1234567890"
      container_name   = "nginx-proxy"
      container_port   = 8081
    }]
  }

  assert {
    condition     = length(aws_ecs_service.this[0].load_balancer) == 2
    error_message = "Unexpected load_balancer length"
  }

  assert {
    condition     = [for lb in aws_ecs_service.this[0].load_balancer : lb][0].target_group_arn == "arn:aws:elasticloadbalancing:ca-central-1:123456789012:targetgroup/tg1/1234567890"
    error_message = "Unexpected target_group_arn value"
  }

  assert {
    condition     = [for lb in aws_ecs_service.this[0].load_balancer : lb][0].container_name == "nginx"
    error_message = "Unexpected container_name value"
  }

  assert {
    condition     = [for lb in aws_ecs_service.this[0].load_balancer : lb][0].container_port == 8080
    error_message = "Unexpected container_port value"
  }

  assert {
    condition     = [for lb in aws_ecs_service.this[0].load_balancer : lb][1].target_group_arn == "arn:aws:elasticloadbalancing:ca-central-1:123456789012:targetgroup/tg2/1234567890"
    error_message = "Unexpected target_group_arn value"
  }

  assert {
    condition     = [for lb in aws_ecs_service.this[0].load_balancer : lb][1].container_name == "nginx-proxy"
    error_message = "Unexpected container_name value"
  }

  assert {
    condition     = [for lb in aws_ecs_service.this[0].load_balancer : lb][1].container_port == 8081
    error_message = "Unexpected container_port value"
  }

  assert {
    condition     = aws_ecs_task_definition.this.container_definitions == "[{\"essential\":false,\"image\":\"nginx:latest\",\"name\":\"init\"},{\"dependsOn\":[{\"condition\":\"SUCCESS\",\"containerName\":\"init\"}],\"essential\":true,\"image\":\"nginx:latest\",\"linuxParameters\":{\"capabilities\":{\"add\":[],\"drop\":[\"ALL\"]}},\"logConfiguration\":{\"logDriver\":\"awslogs\",\"options\":{\"awslogs-group\":\"/aws/ecs/simple_cluster/nginx\",\"awslogs-region\":\"ca-central-1\",\"awslogs-stream-prefix\":\"task\"}},\"mountPoints\":[],\"name\":\"nginx\",\"readonlyRootFilesystem\":true,\"systemControls\":[],\"volumesFrom\":[]},{\"cpu\":128,\"essential\":false,\"image\":\"nginx:latest\",\"memory\":256,\"name\":\"test\"}]"
    error_message = "Unexpected container_definitions value"
  }
}

run "plan_service_connect" {
  command = plan

  variables {
    subnet_ids                    = ["subnet-12345678"]
    security_group_ids            = ["sg-12345678"]
    container_host_port           = 8080
    container_port                = 8080
    service_connect_enabled       = true
    service_connect_namespace_arn = "arn:aws:servicediscovery:ca-central-1:123456789012:namespace/ns-abc123"
  }

  assert {
    condition     = length(aws_ecs_cluster.this[0].service_connect_defaults) == 1
    error_message = "Expected service_connect_defaults to be set on the ECS cluster"
  }

  assert {
    condition     = [for d in aws_ecs_cluster.this[0].service_connect_defaults : d][0].namespace == "arn:aws:servicediscovery:ca-central-1:123456789012:namespace/ns-abc123"
    error_message = "Unexpected service_connect_defaults namespace"
  }

  assert {
    condition     = length(aws_ecs_service.this[0].service_connect_configuration) == 1
    error_message = "Expected service_connect_configuration to be set on the ECS service"
  }

  assert {
    condition     = [for cfg in aws_ecs_service.this[0].service_connect_configuration : cfg][0].enabled == true
    error_message = "Expected service_connect_configuration.enabled to be true"
  }

  assert {
    condition     = [for cfg in aws_ecs_service.this[0].service_connect_configuration : cfg][0].namespace == "arn:aws:servicediscovery:ca-central-1:123456789012:namespace/ns-abc123"
    error_message = "Unexpected service_connect_configuration namespace"
  }

  assert {
    condition     = [for s in [for cfg in aws_ecs_service.this[0].service_connect_configuration : cfg][0].service : s][0].port_name == "nginx"
    error_message = "Unexpected service_connect service port_name"
  }

  assert {
    condition     = [for a in [for s in [for cfg in aws_ecs_service.this[0].service_connect_configuration : cfg][0].service : s][0].client_alias : a][0].port == 8080
    error_message = "Unexpected service_connect service client_alias port"
  }

  assert {
    condition     = [for a in [for s in [for cfg in aws_ecs_service.this[0].service_connect_configuration : cfg][0].service : s][0].client_alias : a][0].dns_name == "nginx"
    error_message = "Unexpected service_connect service client_alias dns_name"
  }

  assert {
    condition     = length(aws_cloudwatch_log_group.this_service_connect) == 1
    error_message = "Expected service connect CloudWatch log group to be created"
  }

  assert {
    condition     = aws_cloudwatch_log_group.this_service_connect[0].name == "/aws/ecs/simple_cluster/nginx-service-connect"
    error_message = "Unexpected service connect CloudWatch log group name"
  }

  assert {
    condition     = jsondecode(aws_ecs_task_definition.this.container_definitions)[0].portMappings[0].name == "nginx-http"
    error_message = "Expected service connect port mapping name in container definition"
  }

  assert {
    condition     = jsondecode(aws_ecs_task_definition.this.container_definitions)[0].portMappings[0].appProtocol == "http"
    error_message = "Expected service connect appProtocol in container definition"
  }
}

run "apply" {
  # Smoke test to validate that the module can successfully be applied
  variables {
    subnet_ids         = run.setup.private_subnet_ids
    security_group_ids = [run.setup.security_group_id]
    task_role_arn      = run.setup.task_role_arn
    task_exec_role_arn = run.setup.task_exec_role_arn

    container_image_track_deployed = true
  }
}
