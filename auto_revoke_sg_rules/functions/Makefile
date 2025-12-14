fmt:
	black . $(ARGS)

install:
	pip3 install --user -r requirements_dev.txt

lint:
	pylint sg_change_auto_response.py

test:
	python -m pytest -s -vv .

.PHONY: \
	fmt \
	install	\
	lint \
	test
