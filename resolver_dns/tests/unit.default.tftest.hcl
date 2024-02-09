provider "aws" {
  region = "ca-central-1"
}

run "setup" {
  module {
    source = "./tests/setup"
  }
}

run "apply" {
  # Smoke test to validate that the module can successfully be applied
  variables {
    vpc_id           = run.setup.vpc_id
    firewall_enabled = true
    allowed_domains  = ["canada.ca.", "*.amazonaws.com."]
  }
}
