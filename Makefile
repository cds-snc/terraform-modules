RESOURCES = \
	rds \
	S3 \
	S3_log_bucket \
	user_login_alarm \
	vpc

.PHONY: help format fmt docs scaffold

help:
	@echo make [COMMAND]
	@echo
	@echo COMMANDS
	@echo "  format      -- Alias for fmt"
	@echo "  fmt         -- Run formatters"
	@echo "  docs        -- Run doc generation"
	@echo "  scaffold    -- Run module scaffolding tool"

format: fmt

fmt: $(addsuffix .fmt,$(RESOURCES))

docs: $(addsuffix .docs,$(RESOURCES))

scaffold:
	@./bin/scaffold.sh

define make-rules

.PHONY: $1.docs $1.fmt

$1.docs:
	@echo "[📝 Generating docs for$1]"
	@$(MAKE) -C $1 docs --no-print-directory

$1.fmt:
	@echo "[💄 Formatting$1]"
	@$(MAKE) -C $1 fmt --no-print-directory

endef
$(foreach component,$(RESOURCES), $(eval $(call make-rules, $(component))))