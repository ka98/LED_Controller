# COCOTB test Makefile

# include common makefile targets for cocotb simulations
# TBD

# variable setting
DUT = to_display

TOPLEVEL_LANG = verilog

VERILOG_SOURCES = \
 $(shell pwd)/../../src/$(DUT).v \

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