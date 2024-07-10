# COCOTB test Makefile

# include common makefile targets for cocotb simulations
# TBD

# variable setting
DUT = bcm

TOPLEVEL_LANG = vhdl

VHDL_SOURCES = \
 $(shell pwd)/../../src/$(DUT).vhd \

TOPLEVEL = $(DUT)
MODULE = test_$(DUT)

SIM=ghdl


# set special args used for HDL compilation
EXTRA_ARGS = -fexplicit


# enable waveform generation
# Use --vcd=<file.vcd> for VCD file formats
# use --wave=<file.ghw> for GHDL Waveform format
#SIM_ARGS=-lxt2

SIM_ARGS=--wave=wave.ghw 

include $(shell cocotb-config --makefiles)/Makefile.sim