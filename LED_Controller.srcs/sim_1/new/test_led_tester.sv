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


module test_led_tester(

    output var o_R0,
    output var o_R1,
    output var o_G0,
    output var o_G1,
    output var o_B0,
    output var o_B1
);

localparam period = 8.0; //125 Mhz
logic clk;
logic reset;
logic i_button;

always 
begin
    clk = 1'b1;
    #(period / 2);
    
    clk = 1'b0;
    #(period / 2);
end

led_tester u_led_tester(
    .i_button (i_button ),
    .i_clk    (clk    ),
    .i_reset  (reset  ),
    .o_R0     (o_R0     ),
    .o_R1     (o_R1     ),
    .o_G0     (o_G0     ),
    .o_G1     (o_G1     ),
    .o_B0     (o_B0     ),
    .o_B1     (o_B1     )
);


initial begin
    reset = 1'b1;
    i_button = 0;
    #period
    reset = 1'b0;
    #period
    #period
    #period
    i_button = 1;
    #period
    #period
    #period
    i_button = 0;
    #period
    i_button = 1;
    #period
    #period
    i_button = 0;
    #period
    #period
    #period
    #period
    #period
    #period
    #period
    i_button = 1;

end



endmodule
