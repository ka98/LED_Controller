SHELL := /bin/bash
VENV_NAME := .cocotb-venv
ACTIVATE_VENV := source $(VENV_NAME)/bin/activate
.PHONY: hw sw

all: 
	make hw sw

hw:
	$(MAKE) all -C hw

sw:
	$(MAKE) all -C sw

run:
	$(MAKE) run -C sw

vivado:
	$(MAKE) vivado -C hw

vitis:
	$(MAKE) vitis -C sw

test:
	# tbd

distclean:
	$(MAKE) distclean -C hw
	$(MAKE) distclean -C sw

env:
	virtualenv -p python3 .cocotb-venv; \
	$(ACTIVATE_VENV); \
	pip install -r requirements.txt

TEST_DIRS := $(wildcard */test/module1)

sim: $(TEST_DIRS)

$(TEST_DIRS):
	$(ACTIVATE_VENV); \
	$(MAKE) -C $@

sim:
	make -C hw sim