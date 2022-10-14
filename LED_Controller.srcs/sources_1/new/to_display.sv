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

    input var [7:0]i_R0,
    input var [7:0]i_R1,
    input var [7:0]i_G0,
    input var [7:0]i_G1,
    input var [7:0]i_B0,
    input var [7:0]i_B1,

    output var o_R0,
    output var o_R1,
    output var o_G0,
    output var o_G1,
    output var o_B0,
    output var o_B1,

    output var o_BLANK,
    output var o_clk,
    output var o_lat,

    output var o_A,
    output var o_B,
    output var o_C,
    output var o_D,
    output var o_E,

    output var [11:0]o_address0,
    output var [11:0]o_address1
);

typedef enum bit[2:0] {
    OUTPUT_DATA,
    BLANK,
    LATCH,
    WAIT,
    CHANGE_ADDRESS
} display_state_t;

display_state_t state = LATCH;
display_state_t next_state;

logic R0;
logic R1;
logic G0;
logic G1;
logic B0;
logic B1;

parameter BIT_DEPTH = 7; //Display Bitrate
parameter RAM_BIT_DEPTH = 8; //Bitrate used in RAM
parameter HORIZONTAL_LENGTH = 64;
parameter VERTICAL_LENGTH = 32; //device the original value by 2 - because of double writing

logic [4:0] row_addr = 0; //up to 32
logic [2:0] line_write_counter = 0;  //bcm for writing 8 bit colors
logic [12:0] write_wait_counter = 0; //lowest [5:0] bits are also x position

always_comb begin : next_state_logic

    next_state = state;

    unique case (state)
        OUTPUT_DATA: begin
            if (write_wait_counter >= HORIZONTAL_LENGTH - 1) begin //continue when writing is done
                next_state = BLANK; 
            end
        end
        BLANK: begin
            next_state = LATCH;
        end
        LATCH: begin
            if (line_write_counter == (BIT_DEPTH - 1)) begin //jump over wait when at LSB
                next_state = CHANGE_ADDRESS;
            end else begin
                next_state = WAIT; 
            end
        end
        WAIT: begin
            if (write_wait_counter >= (HORIZONTAL_LENGTH * 2 ** ((BIT_DEPTH - 1) - line_write_counter)) - 1) begin //if waiting done
                next_state = CHANGE_ADDRESS; 
            end
        end
        CHANGE_ADDRESS: begin
            next_state = OUTPUT_DATA;
        end
    endcase

end

always_comb begin : output_logic

    o_BLANK = 0;
    o_lat = 0;

    o_R0 = 0;
    o_R1 = 0;
    o_G0 = 0;
    o_G1 = 0;
    o_B0 = 0;
    o_B1 = 0;

    unique case (state)
        OUTPUT_DATA: begin
            o_R0 = R0;
            o_R1 = R1;
            o_G0 = G0;
            o_G1 = G1;
            o_B0 = B0;
            o_B1 = B1;
        end
        BLANK: begin
            o_BLANK = 1;
        end
        LATCH: begin
            o_BLANK = 1;
            o_lat = 1;
        end
        WAIT: begin
        end
        CHANGE_ADDRESS: begin
        end
    endcase
end

always_ff @(posedge i_clk or posedge i_reset) begin : name
    if (i_reset) begin
        state <= OUTPUT_DATA;
        row_addr <= 0;
        line_write_counter <= 0;
        write_wait_counter <= 0;
        R0 <= 0;
        R1 <= 0;
        G0 <= 0;
        G1 <= 0;
        B0 <= 0;
        B1 <= 0;

    end
    else begin

        R0 <= i_R0[(RAM_BIT_DEPTH - 1) - line_write_counter];
        R1 <= i_R1[(RAM_BIT_DEPTH - 1) - line_write_counter];
        G0 <= i_G0[(RAM_BIT_DEPTH - 1) - line_write_counter];
        G1 <= i_G1[(RAM_BIT_DEPTH - 1) - line_write_counter];
        B0 <= i_B0[(RAM_BIT_DEPTH - 1) - line_write_counter];
        B1 <= i_B1[(RAM_BIT_DEPTH - 1) - line_write_counter];

        //default:
        state <= next_state;
        row_addr <= row_addr;
        line_write_counter <= line_write_counter;
        write_wait_counter <= write_wait_counter;

        unique case (state)
            OUTPUT_DATA: begin
                write_wait_counter <= write_wait_counter + 1;
            end
            BLANK: begin
                
            end
            LATCH: begin
            end
            WAIT: begin
                write_wait_counter <= write_wait_counter + 1;
            end
            CHANGE_ADDRESS: begin
                write_wait_counter <= 0;

                if (line_write_counter < (BIT_DEPTH - 1)) begin
                    line_write_counter <= line_write_counter + 1;
                end
                else begin

                    line_write_counter <= 0;

                    if (row_addr >= VERTICAL_LENGTH - 1) begin
                        row_addr <= 0; 
                    end else begin
                        row_addr <= row_addr + 1; 
                    end    
                end
            end
        endcase
    end
end

assign {o_E, o_D, o_C, o_B, o_A} = row_addr;

//multiplexer for shift register clock
assign o_clk = (state == OUTPUT_DATA) ? i_clk : 0;

assign o_address0 = write_wait_counter[5:0] + (row_addr * 64); //x
assign o_address1 = write_wait_counter[5:0] + ((row_addr+32) * 64); //y

endmodule
