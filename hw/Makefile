#if LED_Controller folder does not exist - create project, otherwise update source files!

.PHONY: all clean sim

all: 
	make LED_Controller
	make xsa

LED_Controller:
	make create_proj

sim:
	make -C sim

create_proj:
	vivado -mode batch -nojournal -source ./create_proj.tcl

xsa:
	vivado -mode batch -nojournal -source ./generate_xsa.tcl

vivado:
	vivado -mode gui ./LED_Controller/LED_Controller.xpr

clean:
	rm -rf .Xil NA/ vivado.* vivado*.log vivado*debug

distclean:
	make clean
	rm -rf LED_Controller *.xsa
