fmt:
	black . $(ARGS)

install:
	pip3 install --user -r requirements.txt

lint:
	pylint notify_slack.py

test:
	python -m pytest -s -vv .

.PHONY: \
	fmt \
	install	\
	lint \
	test