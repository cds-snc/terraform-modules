/* # Resolver DNS
*  This module enabled resolver DNS query logging so you can see the DNS queries being made by your VPC resources.
*
*  Optionally, it can also enable a resolver DNS firewall that only permits DNS queries for specific domains to resolve.  This helps prevent unexpected egress from your VPC resources.
*
*  ## :warning: Note
*  Although this module helps prevent egress, it doesn't stop direct IP connections when a DNS query is not required.  To fully lock down your VPC egress, you should use Network ACLs and Security Groups that only allow egress to expected destinations.
*/


#
# Route53 resolver DNS logging
#
resource "aws_cloudwatch_log_group" "route53_vpc_dns" {
  name              = "/aws/route53/${var.vpc_id}"
  retention_in_days = 30
  tags              = local.common_tags
}

data "aws_iam_policy_document" "route53_resolver_logging_policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    principals {
      identifiers = ["route53.amazonaws.com"]
      type        = "Service"
    }

    resources = [
      "${aws_cloudwatch_log_group.route53_vpc_dns.arn}/*"
    ]
  }
}

resource "aws_cloudwatch_log_resource_policy" "route53_vpc_dns" {
  policy_document = data.aws_iam_policy_document.route53_resolver_logging_policy.json
  policy_name     = "route53_resolver_logging_policy"
}

resource "aws_route53_resolver_query_log_config" "route53_vpc_dns" {
  name            = "route53_vpc_dns"
  destination_arn = aws_cloudwatch_log_group.route53_vpc_dns.arn
}

resource "aws_route53_resolver_query_log_config_association" "route53_vpc_dns" {
  resolver_query_log_config_id = aws_route53_resolver_query_log_config.route53_vpc_dns.id
  resource_id                  = var.vpc_id
}

#
# Resolve DNS firewall to only allow DNS queries to the `allowed` domains
# and block all other queries
#
resource "aws_route53_resolver_firewall_domain_list" "allowed" {
  count = var.firewall_enabled ? 1 : 0

  name    = "AllowedDomains"
  domains = var.allowed_domains
  tags    = local.common_tags
}

resource "aws_route53_resolver_firewall_domain_list" "blocked" {
  count = var.firewall_enabled ? 1 : 0

  name    = "BlockedDomains"
  domains = ["*."]
  tags    = local.common_tags
}

resource "aws_route53_resolver_firewall_rule_group" "firewall_rules" {
  count = var.firewall_enabled ? 1 : 0

  name = "FirewallRules"
  tags = local.common_tags
}

resource "aws_route53_resolver_firewall_rule" "allowed" {
  count = var.firewall_enabled ? 1 : 0

  name                    = "AllowedDomains"
  action                  = "ALLOW"
  firewall_domain_list_id = aws_route53_resolver_firewall_domain_list.allowed[0].id
  firewall_rule_group_id  = aws_route53_resolver_firewall_rule_group.firewall_rules[0].id
  priority                = 100
}

resource "aws_route53_resolver_firewall_rule" "blocked" {
  count = var.firewall_enabled ? 1 : 0

  name                    = "BlockedDomains"
  action                  = "BLOCK"
  block_response          = "NODATA"
  firewall_domain_list_id = aws_route53_resolver_firewall_domain_list.blocked[0].id
  firewall_rule_group_id  = aws_route53_resolver_firewall_rule_group.firewall_rules[0].id
  priority                = 200
}

resource "aws_route53_resolver_firewall_rule_group_association" "firewall_rules" {
  count = var.firewall_enabled ? 1 : 0

  name                   = "FirewallRules"
  firewall_rule_group_id = aws_route53_resolver_firewall_rule_group.firewall_rules[0].id
  priority               = 101
  vpc_id                 = var.vpc_id
}
