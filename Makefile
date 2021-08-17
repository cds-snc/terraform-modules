.PHONY: fmt
fmt:
	terraform fmt -recursive

.PHONY: docs
docs:
	./bin/generate-docs.sh