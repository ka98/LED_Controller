"""
cocotb testbench for info_block
"""

import sys
import logging
import cocotb
from cocotb.clock import Clock, Timer
from cocotb.triggers import FallingEdge

from cocotb.log import SimLog
from cocotb.triggers import Timer, RisingEdge
from cocotb.utils import get_sim_steps, get_time_from_sim_steps, lazy_property

from cocotbext.axi import AxiLiteBus, AxiLiteMaster
from cocotbext.axi.axil_master import AxiLiteReadResp

#constant

INIT_BLANK = 0
INIT_LATCH = 1
OUTPUT_DATA = 2
BLANK = 3
LATCH = 4
WAIT = 5
CHANGE_ADDRESS = 6

class PORAsync():
    """
    Power On Reset witgh async reset release
    """
    def __init__(self, signal, pulselength, units="step", level=1):
        # initialize the reset module
        self.rst_level = level
        self.period = get_sim_steps(pulselength, units)
        self.frequency = 1.0 / get_time_from_sim_steps(self.period, units="us")
        self.hdl = None
        self.signal = signal
        self.coro = None
        self.mcoro = None

    @lazy_property
    def log(self):
        return SimLog(f"hema_cocotb.{type(self).__qualname__}.{self.signal._name}")


    async def start(self):
        r"""Power on Reset coroutine.
            Start the POR by :func:`cocotb.start`\ ing a call to this.
        """
        # branch outside for loop for performance (decision has to be taken only once)
        # start with applied reset signal
        self.signal.value = self.rst_level
        await Timer(self.period)
        self.signal.value = not self.rst_level

class PORSync():
    """
    Power On Reset with sync reset release
    """    
    def __init__(self, signal, clk_signal, pulselength, units="step", level=1):
        # initialize the reset module
        self.rst_level = level
        self.period = get_sim_steps(pulselength, units)
        self.frequency = 1.0 / get_time_from_sim_steps(self.period, units="us")
        self.hdl = None
        self.signal = signal
        self.clk_signal = clk_signal
        self.coro = None
        self.mcoro = None

    @lazy_property
    def log(self):
        return SimLog(f"hema_cocotb.{type(self).__qualname__}.{self.signal._name}")


    async def start(self):
        r"""Power on Reset coroutine.
            Start the POR by :func:`cocotb.start`\ ing a call to this.
        """
        # branch outside for loop for performance (decision has to be taken only once)
        # start with applied reset signal
        self.signal.value = self.rst_level
        await Timer(self.period)
        await RisingEdge(self.clk_signal)
        self.signal.value = not self.rst_level
        
async def prepare_test(dut):
    # set logger
    dut._log = logging.getLogger("cocotb.tb")
    dut._log.setLevel(logging.DEBUG)

    # -------------------- Instantiate modules --------------------
    # Create and start 10ns clock
    clock = Clock(dut.axi_clk, 33.33, units="ns")
    cocotb.start_soon(clock.start(start_high=False))

    # create and start power on reset
    reset = PORSync(dut.axi_rst, dut.axi_clk, 44, 'ns', 1)
    cocotb.start_soon(reset.start())
    
    # AXI lite master
    axil_master = AxiLiteMaster(AxiLiteBus.from_prefix(dut, "axi4l_s"), dut.axi_clk, dut.axi_rst)

    # wait for the reset to be cleared
    await FallingEdge(dut.axi_rst)
    
    return axil_master

@cocotb.test()
async def smoke_video_buffer_address(dut):
    """ is the address to the video-buffer within bounds? """
    
    dut._log = logging.getLogger("cocotb.tb")
    dut._log.setLevel(logging.DEBUG)

    # -------------------- Instantiate modules --------------------
    # Create and start 10ns clock
    clock = Clock(dut.axi_clk, 33.33, units="ns")
    cocotb.start_soon(clock.start(start_high=False))

    # create and start power on reset
    reset = PORSync(dut.axi_rst, dut.axi_clk, 44, 'ns', 1)
    cocotb.start_soon(reset.start())
    
    # AXI lite master
    axil_master = AxiLiteMaster(AxiLiteBus.from_prefix(dut, "axi4l_s"), dut.axi_clk, dut.axi_rst)

    # wait for the reset to be cleared
    await FallingEdge(dut.axi_rst)
    
    await Timer(100, 'ns')
    
    for address in range (0, 8192, 4):
        await axil_master.write(address, b'\xff\xff\xff\xff')

    await Timer(10, 'ms')