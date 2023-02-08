SHELL := /bin/bash

ws=workspace
xsa=../hw/design_1_wrapper.xsa

plat_name=platform
app_name=app
domain_name=domain
sys_name=sys

.PHONY: all clean

all:
	make workspace
	make run

workspace:
	make create_proj

create_proj:
	xsct -eval "setws $(ws); \
		platform create -name $(plat_name) -hw $(xsa); \
		domain create -name $(domain_name) -os standalone -proc ps7_cortexa9_0; \
		app create -name $(app_name) -platform $(plat_name) -domain $(domain_name) -sysproj $(sys_name) -template {Hello World}; \
		platform active $(plat_name); \
		platform generate; \
		app build $(app_name);"

build: $(ws)/$(app_name)/Debug/makefile
	make -C $(ws)/$(app_name)/Debug all 

run: 
	source /opt/xilinx/Vitis/2022.1/settings64.sh
	xsdb dbg_init.tcl

clean: $(ws)/$(app_name)/Debug/makefile
	make -C $(ws)/$(app_name)/Debug clean
	rm -rf .Xil
	rm -rf *.log

distclean: 
	make clean
	rm -rf $(ws)

vitis: 
	vitis -workspace $(ws)