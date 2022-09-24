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

    output var o_BLANK,
    output var o_clk,
    output var o_lat,

    output var o_A,
    output var o_B,
    output var o_C,
    output var o_D,
    output var o_E
);

typedef enum {
    DEASSERT_BLANK,
    OUTPUT_DATA,
    WAIT,
    ASSERT_BLANK,
    LATCH,
    CHANGE_ADDRESS
} display_state_t;

display_state_t state = LATCH;
display_state_t next_state;

parameter BIT_DEPTH = 8;
parameter HORIZONTAL_LENGTH = 64;
parameter VERTICAL_LENGTH = 32; //device the original value by 2 - because of double writing

logic [4:0] row_addr; //up to 32
logic [2:0] line_write_counter; //bcm for writing 8 bit colors
logic [12:0] write_wait_counter;

always_comb begin : next_state_logic

    next_state = state;

    unique case (state)
        DEASSERT_BLANK: begin
            next_state = OUTPUT_DATA;
        end
        OUTPUT_DATA: begin
            if (write_wait_counter >= HORIZONTAL_LENGTH - 1 && line_write_counter == 0) begin
                next_state = ASSERT_BLANK; 
            end
            else if (write_wait_counter >= HORIZONTAL_LENGTH - 1) begin //if output done
                next_state = WAIT; 
            end 
        end
        WAIT: begin
            if (write_wait_counter >= (HORIZONTAL_LENGTH * 2 ** line_write_counter) - 1)  begin //if waiting done
                next_state = ASSERT_BLANK; 
            end
        end
        ASSERT_BLANK: begin
            next_state = LATCH;
        end
        LATCH: begin
            next_state = CHANGE_ADDRESS;
        end
        CHANGE_ADDRESS: begin
            next_state = DEASSERT_BLANK;
        end
    endcase

end

always_comb begin : output_logic

    o_BLANK = 0;
    o_lat = 0;

    unique case (state)
        DEASSERT_BLANK: begin
        end
        OUTPUT_DATA: begin
        end
        WAIT: begin
        end
        ASSERT_BLANK: begin
            o_BLANK = 1;
        end
        LATCH: begin
            o_BLANK = 1;
            o_lat = 1;
        end
        CHANGE_ADDRESS: begin
            o_BLANK = 1;
        end
    endcase
end

always_ff @(posedge i_clk) begin : name
    if (i_reset) begin
        state <= DEASSERT_BLANK;
        row_addr <= 0;
        line_write_counter <= 0;
        write_wait_counter <= 0;

    end
    else begin

        //default:
        state <= next_state;
        row_addr <= row_addr;
        line_write_counter <= line_write_counter;
        write_wait_counter <= write_wait_counter;

        unique case (state)
            DEASSERT_BLANK: begin
                
            end
            OUTPUT_DATA: begin
                write_wait_counter <= write_wait_counter + 1;
            end
            WAIT: begin
                write_wait_counter <= write_wait_counter + 1;
            end
            ASSERT_BLANK: begin

            end
            CHANGE_ADDRESS: begin
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
            LATCH: begin
                write_wait_counter <= 0;
            end
        endcase
    end
end

assign {o_E, o_D, o_C, o_B, o_A} = row_addr;

//multiplexer for shift register clock
assign o_clk = (state == OUTPUT_DATA) ? i_clk : 0;

assign o_R0 = i_R0;
assign o_R1 = i_R1;
assign o_G0 = i_G0;
assign o_G1 = i_G1;
assign o_B0 = i_B0;
assign o_B1 = i_B1;


endmodule
