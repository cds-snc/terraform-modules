resource "aws_service_discovery_service" "this" {
  count = var.service_discovery_namespace_id != null ? 1 : 0
  name  = local.container_name

  dns_config {
    namespace_id   = var.service_discovery_namespace_id
    routing_policy = "MULTIVALUE"
    dns_records {
      ttl  = 10
      type = "A"
    }
  }

  health_check_custom_config {
    failure_threshold = 5
  }

  tags = local.common_tags
}