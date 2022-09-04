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
    input var [0:0] i_btn,

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
assign reset = i_btn;

tri locked;
tri clk_50Mhz;

clk_wiz_to_50Mhz u_clk_wiz_to_50Mhz(
    .clk_out_50Mhz  (clk_50Mhz),
    .reset          (reset    ),
    .locked         (locked   ),
    .sys_clk_125Mhz (i_sysclk )
);
    

to_display u_to_display(
    .i_clk (clk_50Mhz),
    .i_reset (reset),
    .o_R0  (o_rpio_05),
    .o_R1  (o_rpio_12),
    .o_G0  (o_rpio_13),
    .o_G1  (o_rpio_16),
    .o_B0  (o_rpio_06),
    .o_B1  (o_rpio_23),
    .o_OE  (o_rpio_04),
    .o_clk (o_rpio_17),
    .o_lat (o_rpio_21),
    .o_A   (o_rpio_22),
    .o_B   (o_rpio_26),
    .o_C   (o_rpio_27),
    .o_D   (o_rpio_20),
    .o_E   (o_rpio_24)
);
endmodule
