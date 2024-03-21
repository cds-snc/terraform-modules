.PHONY: fmt docs

fmt:
	@terraform fmt -recursive

docs:
	@terraform-docs markdown -c ../../.terraform-docs.yml . > README.md