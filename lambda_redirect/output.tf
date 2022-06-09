output "hosted_zone_name_servers" {
  value = local.is_create_hosted_zone ? aws_route53_zone.hosted_zone[0].name_servers : [""]
}
