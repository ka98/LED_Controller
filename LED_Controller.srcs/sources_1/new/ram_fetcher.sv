`default_nettype none
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

module ram_fetcher(

    input var i_clk,
    input var i_rst,

    input var [23:0]i_data,
    input var [5:0]i_x, //up to 64
    input var [4:0]i_y, //up to 32

    output var [11:0]o_address,
    output var [7:0]o_R0,
    output var [7:0]o_G0,
    output var [7:0]o_B0,
    output var [7:0]o_R1,
    output var [7:0]o_G1,
    output var [7:0]o_B1

);

logic [7:0]R0;
logic [7:0]G0;
logic [7:0]B0;
logic [7:0]R1;
logic [7:0]G1;
logic [7:0]B1;

typedef enum bit {
    RLOU, //requeset lower output upper
    RUOL  //requeset upper output lower
} fetcher_state_t;

fetcher_state_t state;

always_ff @(posedge i_clk or posedge i_rst) begin : name
    if (i_rst) begin
        state <= RUOL;
        R0 <= 0;
        G0 <= 0;
        B0 <= 0;
        R1 <= 0;
        G1 <= 0;
        B1 <= 0;
    end 
    else begin
        unique case (state)
            RLOU: begin
                state <= RUOL;
                o_address <= i_x + ((i_y+32) * 64);
                R0 <= i_data [23:16];
                G0 <= i_data [15:8];
                B0 <= i_data [7:0];
            end 
            RUOL: begin
                state <= RLOU;
                o_address <= i_x + (i_y * 64);
                R1 <= i_data [23:16];
                G1 <= i_data [15:8];
                B1 <= i_data [7:0];
            end
        endcase
    end
end

assign o_R0 = R0;
assign o_G0 = G0;
assign o_B0 = B0;
assign o_R1 = R1;
assign o_G1 = G1;
assign o_B1 = B1;

endmodule