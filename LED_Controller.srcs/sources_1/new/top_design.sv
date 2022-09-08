`default_nettype none
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/03/2022 08:31:39 PM
// Design Name: 
// Module Name: Top_design
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_design(

    input var i_sysclk,
    input var [1:0] i_btn,
    input var [0:0] i_sw,

    output var o_rpio_04,
    output var o_rpio_05,
    output var o_rpio_06,
    output var o_rpio_12,
    output var o_rpio_13,
    output var o_rpio_16,
    output var o_rpio_17,
    output var o_rpio_20,
    output var o_rpio_21,
    output var o_rpio_22,
    output var o_rpio_23,
    output var o_rpio_24,
    output var o_rpio_26,
    output var o_rpio_27

    );

tri reset;
tri next_testmode;

debouncer reset_debouncer(
    .i_clk    (i_sysclk ),
    .i_rst    (reset    ),
    .i_input  (i_btn[0] ),
    .o_output (reset    )
);

debouncer next_testmode_debouncer(
    .i_clk    (i_sysclk ),
    .i_rst    (reset    ),
    .i_input  (i_btn[1] ),
    .o_output (next_testmode)
);

tri locked;
tri clk_50Mhz;

clk_wiz_to_50Mhz u_clk_wiz_to_50Mhz(
    .clk_out_50Mhz  (clk_50Mhz),
    .reset          (reset    ),
    .locked         (locked   ),
    .sys_clk_125Mhz (i_sysclk )
);

tri red0;
tri red1;
tri green0;
tri green1;
tri blue0;
tri blue1;

led_tester u_led_tester(
    .i_button (next_testmode),
    .i_clk    (clk_50Mhz),
    .i_reset  (reset    ),
    .o_R0     (red0     ),
    .o_R1     (red1     ),
    .o_G0     (green0   ),
    .o_G1     (green1   ),
    .o_B0     (blue0    ),
    .o_B1     (blue1    )
);

tri output_R0;    
tri output_R1;
tri output_G0;
tri output_G1;
tri output_B0;
tri output_B1;
tri output_OE;
tri output_clk;
tri output_lat;
tri output_A;
tri output_B;
tri output_C;
tri output_D;
tri output_E;

to_display u_to_display(
    .i_clk (clk_50Mhz),
    .i_reset (reset),
    .i_R0  (red0     ),
    .i_R1  (red1     ),
    .i_G0  (green0   ),
    .i_G1  (green1   ),
    .i_B0  (blue0    ),
    .i_B1  (blue1    ),
    .o_R0  (output_R0),
    .o_R1  (output_R1),
    .o_G0  (output_G0),
    .o_G1  (output_G1),
    .o_B0  (output_B0),
    .o_B1  (output_B1),
    .o_OE  (output_OE),
    .o_clk (output_clk),
    .o_lat (output_lat),
    .o_A   (output_A),
    .o_B   (output_B),
    .o_C   (output_C),
    .o_D   (output_D),
    .o_E   (output_E)
);

test_output u_test_output(
    .clk        (i_sysclk),
    .probe_in0  (output_R0),
    .probe_in1  (output_R1),
    .probe_in2  (output_G0),
    .probe_in3  (output_G1),
    .probe_in4  (output_B0),
    .probe_in5  (output_B1),
    .probe_in6  (output_OE),
    .probe_in7  (output_lat),
    .probe_in8  (output_A),
    .probe_in9  (output_B),
    .probe_in10 (output_C),
    .probe_in11 (output_D),
    .probe_in12 (output_E)
);

assign o_rpio_05 = output_R0;    
assign o_rpio_12 = output_R1;
assign o_rpio_13 = output_G0;
assign o_rpio_16 = output_G1;
assign o_rpio_06 = output_B0;
assign o_rpio_23 = output_B1;
assign o_rpio_04 = output_OE;
assign o_rpio_17 = output_clk;
assign o_rpio_21 = output_lat;
assign o_rpio_22 = output_A;
assign o_rpio_26 = output_B;
assign o_rpio_27 = output_C;
assign o_rpio_20 = output_D;
assign o_rpio_24 = output_E;


endmodule
