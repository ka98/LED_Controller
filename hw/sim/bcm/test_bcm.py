"""
cocotb testbench for info_block
"""

import sys
import logging
import cocotb
from cocotb.clock import Clock, Timer
from cocotb.triggers import FallingEdge, ClockCycles, with_timeout

from cocotb.log import SimLog
from cocotb.triggers import Timer, RisingEdge
from cocotb.utils import get_sim_steps, get_time_from_sim_steps, lazy_property

#constant

s_write = 0
s_output_disable = 1
s_latch = 2
s_wait = 3

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
    clock = Clock(dut.i_clk, 33.33, units="ns")
    cocotb.start_soon(clock.start(start_high=False))

    # create and start power on reset
    reset = PORSync(dut.i_res, dut.i_clk, 44, 'ns', 1)
    cocotb.start_soon(reset.start())

    # wait for the reset to be cleared
    await FallingEdge(dut.i_res)

@cocotb.test()
async def smoke_video_buffer_address(dut):
    """ is the address to the video-buffer within bounds? """

    await prepare_test(dut)
    await RisingEdge(dut.i_clk)
    dut._log.info(f"r_state={dut.r_state.value.integer}")
    assert int(dut.r_state) == s_write
    #     assert int(dut.o_x) == 0
    await with_timeout(ClockCycles(dut.o_clk, 63), 2150, 'ns')
        # assert int(dut.o_x) == 63

@cocotb.test()
async def smoke_o_clk(dut):
    """ is the output clock set exactly HORIZONTAL_LENGTH Times? """
    
    """This is accomplished by waiting for 32 o_clk cycles
    with a timeout - suitable to 30Mhz"""

    await prepare_test(dut)    
    while int(dut.state) != OUTPUT_DATA:
        await RisingEdge(dut.i_clk)
        
    await with_timeout(ClockCycles(dut.o_clk, int(dut.HORIZONTAL_LENGTH)-1), 2150, 'ns')
    await RisingEdge(dut.i_clk)
    await Timer(1, 'step')
    assert int(dut.state) != OUTPUT_DATA
    
@cocotb.test()
async def smoke_white(dut):
    """ put a white image to the LED """
    
    dut.i_data0.value = 0xFFFFFF
    dut.i_data1.value = 0xFFFFFF

    await prepare_test(dut)
    
    while int(dut.state) != OUTPUT_DATA:
        await RisingEdge(dut.i_clk)
    
    while True:
        await RisingEdge(dut.i_clk)
        if int(dut.state) == OUTPUT_DATA:
            assert dut.o_R0.value
            assert dut.o_R1.value
            assert dut.o_G0.value
            assert dut.o_G1.value
            assert dut.o_B0.value
            assert dut.o_B1.value
            
        if int(dut.state.value) == BLANK:
            break

@cocotb.test()
async def smoke_red(dut):
    """ put a red image to the LED """
    
    dut.i_data0.value = 0xFF0000
    dut.i_data1.value = 0xFF0000

    await prepare_test(dut)
    
    while int(dut.state) != OUTPUT_DATA:
        await RisingEdge(dut.i_clk)
    
    while True:
        await RisingEdge(dut.i_clk)
        if int(dut.state) == OUTPUT_DATA:
            assert dut.o_R0.value
            assert dut.o_R1.value
            assert not dut.o_G0.value
            assert not dut.o_G1.value
            assert not dut.o_B0.value
            assert not dut.o_B1.value
            
        if int(dut.state.value) == BLANK:
            break
        
@cocotb.test()
async def smoke_green(dut):
    """ put a green image to the LED """
    
    dut.i_data0.value = 0x00FF00
    dut.i_data1.value = 0x00FF00

    await prepare_test(dut)
    
    while int(dut.state) != OUTPUT_DATA:
        await RisingEdge(dut.i_clk)
    
    while True:
        await RisingEdge(dut.i_clk)
        if int(dut.state) == OUTPUT_DATA:
            assert not dut.o_R0.value
            assert not dut.o_R1.value
            assert dut.o_G0.value
            assert dut.o_G1.value
            assert not dut.o_B0.value
            assert not dut.o_B1.value
            
        if int(dut.state.value) == BLANK:
            break
        
@cocotb.test()
async def smoke_blue(dut):
    """ put a blue image to the LED """
    
    dut.i_data0.value = 0x0000FF
    dut.i_data1.value = 0x0000FF

    await prepare_test(dut)
    
    while int(dut.state) != OUTPUT_DATA:
        await RisingEdge(dut.i_clk)
    
    while True:
        await RisingEdge(dut.i_clk)
        if int(dut.state) == OUTPUT_DATA:
            assert not dut.o_R0.value
            assert not dut.o_R1.value
            assert not dut.o_G0.value
            assert not dut.o_G1.value
            assert dut.o_B0.value
            assert dut.o_B1.value
            
        if int(dut.state.value) == BLANK:
            break

@cocotb.test()
async def smoke_custom_color(dut):
    """ put a water blue (0x256D7B) and May green (0x4C9141) to the LED """
    
    bit_depth = int(dut.BIT_DEPTH)
    
    dut.i_data0.value = 0x256D7B
    dut.i_data1.value = 0x4C9141
    
    red0 = ('{0:08b}'.format(0x25))
    green0 = ('{0:08b}'.format(0x6d))
    blue0 = ('{0:08b}'.format(0x7b))
    
    red1 = ('{0:08b}'.format(0x4c))
    green1 = ('{0:08b}'.format(0x91))
    blue1 = ('{0:08b}'.format(0x41))

    await prepare_test(dut)
    
    for i in range(bit_depth):
    
        while int(dut.state) != OUTPUT_DATA:
            await RisingEdge(dut.i_clk)

        while True:
            await RisingEdge(dut.i_clk)
            if int(dut.state) == OUTPUT_DATA:
                assert int(dut.o_R0.value) == int(red0[i])
                assert int(dut.o_R1.value) == int(red1[i])
                assert int(dut.o_G0.value) == int(green0[i])
                assert int(dut.o_G1.value) == int(green1[i])
                assert int(dut.o_B0.value) == int(blue0[i])
                assert int(dut.o_B1.value) == int(blue1[i])
                
            if int(dut.state.value) == BLANK:
                break

@cocotb.test()
async def table_bcm_timing(dut):
    """ put a water blue (0x256D7B) and May green (0x4C9141) to the LED """
    
    bit_depth = int(dut.BIT_DEPTH)

    await prepare_test(dut)
    
    cycles = []
    counter = 0
    
    for i in range(bit_depth):
    
        while int(dut.state.value) != CHANGE_ADDRESS:
            await RisingEdge(dut.i_clk)
            counter += 1
            
        cycles.append(counter)
        counter = 0
        
        await RisingEdge(dut.i_clk)
        
    dut._log.info(cycles)
