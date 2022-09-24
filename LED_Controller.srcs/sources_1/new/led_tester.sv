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


module led_tester(

    input var i_button,
    input var i_clk,
    input var i_reset,

    output var o_R0,
    output var o_R1,
    output var o_G0,
    output var o_G1,
    output var o_B0,
    output var o_B1

);

typedef enum logic[2:0] {
        BLACK = 0,
        RED = 1,
        GREEN = 2,
        YELLOW = 3,
        BLUE = 4,
        MAGENTA = 5,
        CYAN = 6,
        WHITE = 7
    } color_t;

color_t state; 
color_t next_state; 

logic is_being_pressed = 0;

always_comb begin : output_logic
    {o_B0, o_G0, o_R0} = state;
    {o_B1, o_G1, o_R1} = state;
end

always_ff @(posedge i_clk) begin : state_logic
    if (i_reset) begin
        state <= RED;
    end
    else begin
        if (i_button && !is_being_pressed) begin
            next_state <= color_t'(state + 1);
            is_being_pressed <= 1;
        end 
        else if (!i_button) begin
            next_state <= state;
            is_being_pressed <= 0;
        end
        else begin
            next_state <= state;
            is_being_pressed <= is_being_pressed;
        end
        state <= next_state;
    end
end

endmodule
