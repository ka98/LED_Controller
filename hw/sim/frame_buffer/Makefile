# COCOTB test Makefile

# include common makefile targets for cocotb simulations
# TBD

# variable setting
DUT = top_level

TOPLEVEL_LANG = verilog

VERILOG_SOURCES = \
 $(shell pwd)/../../src/$(DUT).v \
 $(shell pwd)/../../src/rams_dist.v \
 $(shell pwd)/../../src/axi4_lite_slave.v \
 $(shell pwd)/../../src/to_display.v \

TOPLEVEL = $(DUT)
MODULE = test_$(DUT)

SIM=verilator


# set special args used for HDL compilation
EXTRA_ARGS = --coverage --trace-fst --trace-structs


# enable waveform generation
# Use --vcd=<file.vcd> for VCD file formats
# use --wave=<file.ghw> for GHDL Waveform format
#SIM_ARGS=-lxt2

include $(shell cocotb-config --makefiles)/Makefile.sim