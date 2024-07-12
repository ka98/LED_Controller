"""
cocotb testbench for info_block
"""

import sys
import logging
import cocotb
from cocotb.clock import Clock, Timer
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles, with_timeout

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
    reset = PORSync(dut.i_res, dut.i_clk, 50, 'ns', 1)
    cocotb.start_soon(reset.start())

    # wait for the reset to be cleared
    await FallingEdge(dut.i_res)
    await Timer(1, 'step')

@cocotb.test()
async def smoke_video_buffer_address_horizontal(dut):
    """ is the horizontal address to the video-buffer within bounds? """

    await prepare_test(dut)

    while int(dut.r_state) != s_write:
        await RisingEdge(dut.i_clk)

    dut._log.info(f"r_state={int(dut.r_state)}")
    assert int(dut.r_state) == s_write
    for asserted_address in range(64) :    
        dut._log.info(f"asserted_address={asserted_address}")
        assert int(dut.o_address) == asserted_address
        await with_timeout(RisingEdge(dut.i_clk), 35, 'ns')
        await Timer(1)

@cocotb.test()
async def smoke_lat_oe(dut):
    """ do lat and oe output data? """

    await prepare_test(dut)
    

    while int(dut.r_state) != s_write:
        await RisingEdge(dut.i_clk)
    
    while int(dut.r_state) == s_write:
        assert int(dut.o_oe) == 1
        assert int(dut.o_lat) == 0
        await RisingEdge(dut.i_clk)
    assert int(dut.r_state) == s_output_disable
    assert int(dut.o_oe) == 0
    assert int(dut.o_lat) == 0
    await RisingEdge(dut.i_clk)
    assert int(dut.r_state) == s_latch
    assert int(dut.o_oe) == 0
    assert int(dut.o_lat) == 1
    
@cocotb.test()
async def smoke_white(dut):
    """ put a white image to the LED """
    
    dut.i_data0.value = 0xFFFFFF
    dut.i_data1.value = 0xFFFFFF

    await prepare_test(dut)
    
    while int(dut.r_state) != s_write:
        await RisingEdge(dut.i_clk)
    
    while True:
        await RisingEdge(dut.i_clk)
        if int(dut.r_state) == s_write:
            assert int(dut.o_data0) == 0b111
            assert int(dut.o_data1) == 0b111
            
        if int(dut.r_state.value) == s_output_disable:
            break

@cocotb.test()
async def smoke_red(dut):
    """ put a red image to the LED """
    
    dut.i_data0.value = 0xFF0000
    dut.i_data1.value = 0xFF0000

    await prepare_test(dut)
    
    while int(dut.r_state) != s_write:
        await RisingEdge(dut.i_clk)
    
    while True:
        await RisingEdge(dut.i_clk)
        if int(dut.r_state) == s_write:
            assert int(dut.o_data0) == 0b100
            assert int(dut.o_data1) == 0b100
            
        if int(dut.r_state.value) == s_output_disable:
            break
        
@cocotb.test()
async def smoke_green(dut):
    """ put a green image to the LED """
    
    dut.i_data0.value = 0x00FF00
    dut.i_data1.value = 0x00FF00

    await prepare_test(dut)
    
    while int(dut.r_state) != s_write:
        await RisingEdge(dut.i_clk)
    
    while True:
        await RisingEdge(dut.i_clk)
        if int(dut.r_state) == s_write:
            assert int(dut.o_data0) == 0b010
            assert int(dut.o_data1) == 0b010
            
        if int(dut.r_state.value) == s_output_disable:
            break
        
@cocotb.test()
async def smoke_blue(dut):
    """ put a blue image to the LED """
    
    dut.i_data0.value = 0x0000FF
    dut.i_data1.value = 0x0000FF

    await prepare_test(dut)
    
    while int(dut.r_state) != s_write:
        await RisingEdge(dut.i_clk)
    
    while True:
        await RisingEdge(dut.i_clk)
        if int(dut.r_state) == s_write:
            assert int(dut.o_data0) == 0b001
            assert int(dut.o_data1) == 0b001
            
        if int(dut.r_state.value) == s_output_disable:
            break

@cocotb.test()
async def smoke_custom_color(dut):
    """ put a water blue (0x256D7B) and May green (0x4C9141) to the LED """
    
    dut.i_data0.value = 0x256D7B
    dut.i_data1.value = 0x4C9141
    
    red0 = ('{0:08b}'.format(0x25))
    green0 = ('{0:08b}'.format(0x6d))
    blue0 = ('{0:08b}'.format(0x7b))
    
    red1 = ('{0:08b}'.format(0x4c))
    green1 = ('{0:08b}'.format(0x91))
    blue1 = ('{0:08b}'.format(0x41))

    await prepare_test(dut)
    
    for i in range(int(dut.BIT_DEPTH)):
    
        while int(dut.r_state) != s_write:
            await RisingEdge(dut.i_clk)

        while int(dut.r_state) == s_write:
            # dut._log.info(f"bcm_phase={int(dut.r_bcm_phase)}")
            # dut._log.info(f"red_full_value={red1}")
            # dut._log.info(f"red[7-{i}]={red1[int(dut.BIT_DEPTH)-1-i]}")
            # dut._log.info(f"o_data1a_value={dut.o_data1.value}")
            # dut._log.info(f"o_data1_value[2]={dut.o_data1.value[2]}")
            assert int(dut.o_data0.value[0]) == int(red0[int(dut.BIT_DEPTH)-1-i])
            assert int(dut.o_data1.value[0]) == int(red1[int(dut.BIT_DEPTH)-1-i])
            assert int(dut.o_data0.value[1]) == int(green0[int(dut.BIT_DEPTH)-1-i])
            assert int(dut.o_data1.value[1]) == int(green1[int(dut.BIT_DEPTH)-1-i])
            assert int(dut.o_data0.value[2]) == int(blue0[int(dut.BIT_DEPTH)-1-i])
            assert int(dut.o_data1.value[2]) == int(blue1[int(dut.BIT_DEPTH)-1-i])
            await RisingEdge(dut.i_clk)

@cocotb.test()
async def smoke_video_buffer_addres_vertical(dut):
    """ is the horizontal address to the video-buffer within bounds? """

    await prepare_test(dut)

    for i in range(32):
        for j in range(int(dut.BIT_DEPTH)):
            for k in range(64) :    
                while int(dut.r_state) != s_write:
                    await RisingEdge(dut.i_clk)
                    await Timer(1)
                dut._log.info(f"asserted_address={i*64+k}")
                assert int(dut.o_address) == i*64+k
                await with_timeout(RisingEdge(dut.i_clk), 35, 'ns')
                await Timer(1)

@cocotb.test()
async def table_bcm_timing(dut):
    """ check timing of bcm phases """

    await prepare_test(dut)
    
    cycles = []
    counter = 0
    
    for i in range(int(dut.BIT_DEPTH)):
    
        while int(dut.r_bcm_phase) == i:
            counter += 1
            await RisingEdge(dut.i_clk)
            
            
        cycles.append(counter)
        counter = 0
        
    dut._log.info(f"cycles={cycles}")
    dut._log.info(f"one line takes={sum(cycles)}")
    dut._log.info(f"one frame takes={sum(cycles)*32}")
    dut._log.info(f"one frame takes={(sum(cycles)*32) / 30_000_000}s")
    dut._log.info(f"dispaly will run at={1/((sum(cycles)*32) / 30_000_000)}hz")

    for idx, value in enumerate(cycles):
        if idx > 0:
            assert cycles[idx-1] < value, "cycles is not ascending monotone"