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