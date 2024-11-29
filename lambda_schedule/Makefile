.PHONY: fmt docs test

fmt:
	@terraform fmt -recursive

docs:
	@rm -rf .terraform
	@rm -f .terraform.lock.hcl
	@terraform-docs markdown -c ../.terraform-docs.yml . > README.md

test:
	@terraform init
	terraform test --var-file=./tests/globals.tfvars	
