`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/03/2022 08:19:58 PM
// Design Name: 
// Module Name: To_Display
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


module to_display_wrapper(
    input i_clk,
    input i_reset,

    input [23:0]i_data0,
    input [23:0]i_data1,

    output o_R0,
    output o_R1,
    output o_G0,
    output o_G1,
    output o_B0,
    output o_B1,

    output o_BLANK,
    output o_clk,
    output o_lat,

    output o_A,
    output o_B,
    output o_C,
    output o_D,
    output o_E,

    output [10:0]o_address
);

wire [7:0]w_R0;
wire [7:0]w_G0;
wire [7:0]w_B0;
wire [7:0]w_R1;
wire [7:0]w_G1;
wire [7:0]w_B1;

assign i_data0 = {w_R0, w_G0, w_B0};
assign i_data1 = {w_R1, w_G1, w_B1};

parameter BIT_DEPTH = 7; //Display Bitrate
parameter RAM_BIT_DEPTH = 8; //Bitrate used in RAM
parameter HORIZONTAL_LENGTH = 64;
parameter VERTICAL_LENGTH = 32; //device the original value by 2 - because of double writing

to_display 
#(
    .BIT_DEPTH         (BIT_DEPTH         ),
    .RAM_BIT_DEPTH     (RAM_BIT_DEPTH     ),
    .HORIZONTAL_LENGTH (HORIZONTAL_LENGTH ),
    .VERTICAL_LENGTH   (VERTICAL_LENGTH   )
)
u_to_display(
    .i_clk     (i_clk     ),
    .i_reset   (i_reset   ),
    .i_R0      (w_R0      ),
    .i_R1      (w_R1      ),
    .i_G0      (w_G0      ),
    .i_G1      (w_G1      ),
    .i_B0      (w_B0      ),
    .i_B1      (w_B1      ),
    .o_R0      (o_R0      ),
    .o_R1      (o_R1      ),
    .o_G0      (o_G0      ),
    .o_G1      (o_G1      ),
    .o_B0      (o_B0      ),
    .o_B1      (o_B1      ),
    .o_BLANK   (o_BLANK   ),
    .o_clk     (o_clk     ),
    .o_lat     (o_lat     ),
    .o_A       (o_A       ),
    .o_B       (o_B       ),
    .o_C       (o_C       ),
    .o_D       (o_D       ),
    .o_E       (o_E       ),
    .o_address (o_address )
);



endmodule