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


module sim_top_design(

    input var i_sysclk,
    input var [1:0] i_btn,

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
    output var o_rpio_27,

    output var [3:0] o_led

    );

tri reset;
tri reset_ps_clk;
assign reset = i_btn[0];

tri clk_125Mhz;
tri clk_50Mhz;
tri clk_5Mhz;
tri locked;

assign clk_125Mhz = i_sysclk;

assign o_led[0] = reset;
assign o_led[1] = i_sysclk;
assign o_led[2] = clk_50Mhz;
assign o_led[3] = locked;

tri red0;
tri red1;
tri green0;
tri green1;
tri blue0;
tri blue1;

tri output_R0;    
tri output_R1;
tri output_G0;
tri output_G1;
tri output_B0;
tri output_B1;
tri output_BLANK;
tri output_clk;
tri output_lat;
tri output_A;
tri output_B;
tri output_C;
tri output_D;
tri output_E;

tri reset_to_display;
assign reset_to_display = reset || !locked;


clk_wiz_1 u_clk_wiz_1(
    .clk_out1 (clk_50Mhz ),
    .reset    (reset    ),
    .locked   (locked   ),
    .clk_in1  (clk_125Mhz  )
);

to_display u_to_display(
    .i_clk (clk_50Mhz),
    .i_reset (reset_to_display),
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
    .o_BLANK  (output_BLANK),
    .o_clk (output_clk),
    .o_lat (output_lat),
    .o_A   (output_A),
    .o_B   (output_B),
    .o_C   (output_C),
    .o_D   (output_D),
    .o_E   (output_E)
);

assign o_rpio_05 = output_R0;    
assign o_rpio_12 = output_R1;
assign o_rpio_13 = output_G0;
assign o_rpio_16 = output_G1;
assign o_rpio_06 = output_B0;
assign o_rpio_23 = output_B1;
assign o_rpio_04 = output_BLANK;
assign o_rpio_17 = output_clk;
assign o_rpio_21 = output_lat;
assign o_rpio_22 = output_A;
assign o_rpio_26 = output_B;
assign o_rpio_27 = output_C;
assign o_rpio_20 = output_D;
assign o_rpio_24 = output_E;


endmodule
