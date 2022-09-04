`default_nettype none
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/04/2022 09:58:07 AM
// Design Name: 
// Module Name: Smoke_Test
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


module smoke_test(
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

localparam period = 8.0; //125 Mhz
logic clk;
logic reset;

always 
begin
    clk = 1'b1;
    #(period / 2);
    
    clk = 1'b0;
    #(period / 2);
end

top_design u_top_design(
    .i_sysclk  (clk       ),
    .i_btn     (reset     ),
    .o_rpio_04 (o_rpio_04 ),
    .o_rpio_05 (o_rpio_05 ),
    .o_rpio_06 (o_rpio_06 ),
    .o_rpio_12 (o_rpio_12 ),
    .o_rpio_13 (o_rpio_13 ),
    .o_rpio_16 (o_rpio_16 ),
    .o_rpio_17 (o_rpio_17 ),
    .o_rpio_20 (o_rpio_20 ),
    .o_rpio_21 (o_rpio_21 ),
    .o_rpio_22 (o_rpio_22 ),
    .o_rpio_23 (o_rpio_23 ),
    .o_rpio_24 (o_rpio_24 ),
    .o_rpio_26 (o_rpio_26 ),
    .o_rpio_27 (o_rpio_27 )
);

initial begin
    reset = 1'b1;
    #period
    reset = 1'b0;
end



endmodule
