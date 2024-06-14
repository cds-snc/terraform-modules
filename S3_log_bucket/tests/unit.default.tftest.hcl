provider "aws" {
  region = "ca-central-1"
}

run "setup" {
  module {
    source = "./tests/setup"
  }
}

run "apply_basic" {
  # Smoke test to validate that the module can successfully be applied
  variables {
    bucket_name = "just-a-log-bucket-test-${run.setup.random_pet}"
  }
}
