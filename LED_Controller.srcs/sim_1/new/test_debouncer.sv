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


module test_debouncer(
    output var o_output
);

localparam period = 8.0; //125 Mhz
logic clk;
logic reset;
logic i_input;

always 
begin
    clk = 1'b1;
    #(period / 2);
    
    clk = 1'b0;
    #(period / 2);
end

debouncer u_debouncer(
    .i_clk    (clk    ),
    .i_rst    (reset    ),
    .i_input  (i_input  ),
    .o_output (o_output )
);


initial begin
    reset = 1'b1;
    #period
    reset = 1'b0;
    #period
    #period
    #period
    i_input = 1;
end



endmodule
