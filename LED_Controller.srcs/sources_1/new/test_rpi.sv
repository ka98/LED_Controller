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


module test_rpi(

    input var i_sysclk,

    output var o_rpio_02,
    output var o_rpio_03,
    output var o_rpio_04,
    output var o_rpio_14,
    output var o_rpio_15,
    output var o_rpio_17,
    output var o_rpio_18,
    output var o_rpio_27,
    output var o_rpio_22,
    output var o_rpio_23,
    output var o_rpio_24,
    output var o_rpio_10,
    output var o_rpio_09,
    output var o_rpio_25,
    output var o_rpio_11,
    output var o_rpio_08,
    output var o_rpio_07,
    output var o_rpio_sd,
    output var o_rpio_sc,
    output var o_rpio_05,
    output var o_rpio_06,
    output var o_rpio_12,
    output var o_rpio_13,
    output var o_rpio_19,
    output var o_rpio_16,
    output var o_rpio_26,
    output var o_rpio_20,
    output var o_rpio_21

    );

tri locked;
tri clk_50Mhz;

clk_wiz_to_50Mhz u_clk_wiz_to_50Mhz(
    .clk_out_50Mhz  (clk_50Mhz),
    .reset          (1'b0    ),
    .locked         (locked   ),
    .sys_clk_125Mhz (i_sysclk )
);

test_rpi_ports u_test_rpi_ports(
    .clk         (clk_50Mhz   ),
    .probe_out0  (o_rpio_02  ),
    .probe_out1  (o_rpio_03  ),
    .probe_out2  (o_rpio_04  ),
    .probe_out3  (o_rpio_05  ),
    .probe_out4  (o_rpio_06  ),
    .probe_out5  (o_rpio_07  ),
    .probe_out6  (o_rpio_08  ),
    .probe_out7  (o_rpio_09  ),
    .probe_out8  (o_rpio_10  ),
    .probe_out9  (o_rpio_11  ),
    .probe_out10 (o_rpio_12 ),
    .probe_out11 (o_rpio_13 ),
    .probe_out12 (o_rpio_14 ),
    .probe_out13 (o_rpio_15 ),
    .probe_out14 (o_rpio_16 ),
    .probe_out15 (o_rpio_18 ),
    .probe_out16 (o_rpio_19 ),
    .probe_out17 (o_rpio_20 ),
    .probe_out18 (o_rpio_21 ),
    .probe_out19 (o_rpio_22 ),
    .probe_out20 (o_rpio_23 ),
    .probe_out21 (o_rpio_24 ),
    .probe_out22 (o_rpio_25 ),
    .probe_out23 (o_rpio_26 ),
    .probe_out24 (o_rpio_27 ),
    .probe_out25 (o_rpio_sd ),
    .probe_out26 (o_rpio_sc )

);

assign o_rpio_17 = clk_50Mhz;


endmodule