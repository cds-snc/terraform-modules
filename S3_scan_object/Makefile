.PHONY: fmt docs lambda-install lambda-test

fmt:
	@terraform fmt -recursive

docs:
	@terraform-docs markdown -c ../.terraform-docs.yml . > README.md

lambda-install:
	cd lambda &&\
	pip3 install -r requirements.txt

lambda-test:
	cd lambda &&\
	python3 -m pytest -s -vv .