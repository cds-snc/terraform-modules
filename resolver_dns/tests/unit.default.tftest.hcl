provider "aws" {
  region = "ca-central-1"
}

run "setup" {
  module {
    source = "./tests/setup"
  }
}

run "default_firewall_domain_redirection_action" {
  command = plan

  variables {
    vpc_id           = run.setup.vpc_id
    firewall_enabled = true
    allowed_domains  = ["canada.ca.", "*.amazonaws.com."]
  }

  assert {
    condition     = aws_route53_resolver_firewall_rule.allowed[0].firewall_domain_redirection_action == "INSPECT_REDIRECTION_DOMAIN"
    error_message = "aws_route53_resolver_firewall_rule.allowed[0].firewall_domain_redirection_action did not match expected value"
  }
}

run "trust_redirection_domain" {
  command = plan

  variables {
    vpc_id                             = run.setup.vpc_id
    firewall_enabled                   = true
    allowed_domains                    = ["canada.ca.", "*.amazonaws.com."]
    firewall_domain_redirection_action = "TRUST_REDIRECTION_DOMAIN"
  }

  assert {
    condition     = aws_route53_resolver_firewall_rule.allowed[0].firewall_domain_redirection_action == "TRUST_REDIRECTION_DOMAIN"
    error_message = "aws_route53_resolver_firewall_rule.allowed[0].firewall_domain_redirection_action did not match expected value"
  }
}

run "invalid_firewall_domain_redirection_action" {
  command = plan

  variables {
    vpc_id                             = run.setup.vpc_id
    firewall_enabled                   = true
    allowed_domains                    = ["canada.ca.", "*.amazonaws.com."]
    firewall_domain_redirection_action = "INVALID_VALUE"
  }

  expect_failures = [
    var.firewall_domain_redirection_action,
  ]
}

run "apply" {
  # Smoke test to validate that the module can successfully be applied
  variables {
    vpc_id           = run.setup.vpc_id
    firewall_enabled = true
    allowed_domains  = ["canada.ca.", "*.amazonaws.com."]
  }
}
