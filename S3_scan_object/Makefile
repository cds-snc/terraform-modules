.PHONY: fmt docs lambda-install lambda-test

fmt:
	@terraform fmt -recursive

docs:
	@rm -rf .terraform
	@rm -f .terraform.lock.hcl
	@terraform-docs markdown -c ../.terraform-docs.yml . > README.md

lambda-install:
	cd lambda &&\
	pip3 install -r requirements.txt

lambda-test:
	cd lambda &&\
	AWS_DEFAULT_REGION=ca-central-1 python3 -m pytest -s -vv .