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


module to_display(
    input var i_clk,
    input var i_reset,

    input var i_R0,
    input var i_R1,
    input var i_G0,
    input var i_G1,
    input var i_B0,
    input var i_B1,

    output var o_R0,
    output var o_R1,
    output var o_G0,
    output var o_G1,
    output var o_B0,
    output var o_B1,

    output var o_OE,
    output var o_clk,
    output var o_lat,

    output var o_A,
    output var o_B,
    output var o_C,
    output var o_D,
    output var o_E
);

enum int unsigned {
    OUTPUT_DATA = 0,
    JUMP_TO_START = 1,
    CHANGE_ROW = 2
}
state = OUTPUT_DATA,
next_state;

int unsigned BIT_DEPTH = 8;
int unsigned HORIZONTAL_LENGTH = 64;
int unsigned VERTICAL_LENGTH = 32; //device the original value by 2 - because of double writing

logic [5:0] column_addr; //up to 64
logic [4:0] row_addr; //up to 32
logic [2:0] value; // value R G B
logic [2:0] line_write_counter; //bcm for writing 8 bit colors
logic [8:0] clock_counter = 1;

var internal_clk;

always_comb begin : next_state_logic

    case (state)
        OUTPUT_DATA: begin
            if (column_addr >= HORIZONTAL_LENGTH - 1 && clock_counter >= 2 ** line_write_counter && line_write_counter >= BIT_DEPTH - 1) begin
                next_state = CHANGE_ROW;
            end
            else if (column_addr >= HORIZONTAL_LENGTH - 1 && clock_counter >= 2 ** line_write_counter) begin
                next_state = JUMP_TO_START;
            end
            else begin 
                next_state = OUTPUT_DATA;
            end
        end
        JUMP_TO_START:
            next_state = OUTPUT_DATA;
        CHANGE_ROW: begin
            next_state = OUTPUT_DATA;
        end
    endcase
end

always_comb begin : output_logic
    case (state) 
        OUTPUT_DATA: begin
            o_lat = 1'b0;
            o_OE = 1'b1;
            
            o_R0 = i_R0;
            o_R1 = i_R1;
            o_G0 = i_G0;
            o_G1 = i_G1;
            o_B0 = i_B0;
            o_B1 = i_B1;
            internal_clk = (clock_counter <= (2 ** (line_write_counter-1)));

        end
        JUMP_TO_START: begin
            o_lat = 1'b1;
            o_OE = 1'b1;
            internal_clk = 1'b0;
        end

        CHANGE_ROW: begin
            o_lat = 1'b1;
            o_OE = 1'b0;
            internal_clk = 1'b0;
        end
    endcase
end

always_ff @(posedge i_clk) begin : name
    if (i_reset) begin
        state <= OUTPUT_DATA;
        column_addr <= 6'b000000;
        row_addr <= 5'b00000;
        line_write_counter <= 3'b000;
        clock_counter <= 1;
    end
    else begin
        case (state)
            OUTPUT_DATA: begin
                if(clock_counter >= 2 ** line_write_counter) begin
                    clock_counter <= 1;
                    column_addr <= column_addr + 1;
                end
                else begin
                    clock_counter <= clock_counter + 1;
                end
            end
            JUMP_TO_START: begin
                clock_counter <= 1;
                column_addr <= 0;
                line_write_counter <= line_write_counter + 1;
            end
            CHANGE_ROW: begin
                if (row_addr < VERTICAL_LENGTH) begin
                    row_addr <= row_addr + 1;
                end
                else begin
                    row_addr = 0;
                end
                clock_counter <= 1;
                line_write_counter <= 0;
            end
        endcase

        //clock devider logic goes here:

        state <= next_state;
    end
end

assign {o_E, o_D, o_C, o_B, o_A} = row_addr;

//multiplexer
assign o_clk = (state == OUTPUT_DATA && line_write_counter == 0) ? i_clk : (state == OUTPUT_DATA) ? internal_clk : 0;


endmodule
