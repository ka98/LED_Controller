`timescale 1ns / 1ps


module to_display(
    input i_clk,
    input i_reset,

    input [23:0]i_data0,
    input [23:0]i_data1,

    output reg o_R0,
    output reg o_R1,
    output reg o_G0,
    output reg o_G1,
    output reg o_B0,
    output reg o_B1,

    output reg o_BLANK,
    output o_clk,
    output reg o_lat,

    output o_A,
    output o_B,
    output o_C,
    output o_D,
    output o_E,

    output [10:0]o_address
);

localparam [2:0]
    INIT_BLANK = 3'b000,
    INIT_LATCH = 3'b001,
    OUTPUT_DATA = 3'b010,
    BLANK = 3'b011,
    LATCH = 3'b100,
    WAIT = 3'b101,
    CHANGE_ADDRESS = 3'b110;

reg [2:0] state = LATCH;
reg [2:0] next_state;

wire [7:0] w_R0;
wire [7:0] w_R1;
wire [7:0] w_G0;
wire [7:0] w_G1;
wire [7:0] w_B0;
wire [7:0] w_B1;

assign {w_R0, w_G0, w_B0} = i_data0;
assign {w_R1, w_G1, w_B1} = i_data1;

reg R0;
reg R1;
reg G0;
reg G1;
reg B0;
reg B1;

parameter BIT_DEPTH = 7; //Display Bitrate
parameter RAM_BIT_DEPTH = 8; //Bitrate used in RAM
parameter HORIZONTAL_LENGTH = 64;
parameter VERTICAL_LENGTH = 32; //device the original value by 2 - because of double writing

reg [4:0] row_addr = 0; //up to 32
reg [2:0] line_write_counter = 0;  //bcm for writing 8 bit colors
reg [12:0] write_wait_counter = 0; //lowest [5:0] bits are also x position

always @(*) begin : next_state_logic

    next_state = state;

    case (state)

        INIT_BLANK: begin
            next_state = INIT_LATCH;
        end
        INIT_LATCH: begin
            next_state = OUTPUT_DATA;
        end
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
        default: begin
            //reset if invalid state
            next_state = OUTPUT_DATA;
        end
    endcase

end

always @(*) begin : output_logic

    o_BLANK = 0;
    o_lat = 0;

    o_R0 = 0;
    o_R1 = 0;
    o_G0 = 0;
    o_G1 = 0;
    o_B0 = 0;
    o_B1 = 0;

    case (state)
        OUTPUT_DATA: begin
            o_R0 = R0;
            o_R1 = R1;
            o_G0 = G0;
            o_G1 = G1;
            o_B0 = B0;
            o_B1 = B1;
        end
        INIT_BLANK: begin
            o_BLANK = 1;
        end
        BLANK: begin
            o_BLANK = 1;
        end
        INIT_LATCH: begin
            o_BLANK = 1;
            o_lat = 1;
        end
        LATCH: begin
            o_BLANK = 1;
            o_lat = 1;
        end
        // WAIT: begin
        // end
        // CHANGE_ADDRESS: begin
        // end
        default: begin
            o_BLANK = 0;
            o_lat = 0;

            o_R0 = 0;
            o_R1 = 0;
            o_G0 = 0;
            o_G1 = 0;
            o_B0 = 0;
            o_B1 = 0;
        end
    endcase
end

always @(posedge i_clk or posedge i_reset) begin : name
    if (i_reset) begin
        state <= INIT_BLANK;
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

        R0 <= w_R0[(RAM_BIT_DEPTH - 1) - line_write_counter];
        R1 <= w_R1[(RAM_BIT_DEPTH - 1) - line_write_counter];
        G0 <= w_G0[(RAM_BIT_DEPTH - 1) - line_write_counter];
        G1 <= w_G1[(RAM_BIT_DEPTH - 1) - line_write_counter];
        B0 <= w_B0[(RAM_BIT_DEPTH - 1) - line_write_counter];
        B1 <= w_B1[(RAM_BIT_DEPTH - 1) - line_write_counter];

        //default:
        state <= next_state;
        row_addr <= row_addr;
        line_write_counter <= line_write_counter;
        write_wait_counter <= write_wait_counter;

        case (state)
            OUTPUT_DATA: begin
                write_wait_counter <= write_wait_counter + 1;
            end
            INIT_BLANK: begin
                
            end
            INIT_LATCH: begin
                
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
            default: begin
                //reset if invalid state
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
        endcase
    end
end

assign {o_E, o_D, o_C, o_B, o_A} = row_addr;

//multiplexer for shift register clock
assign o_clk = (state == OUTPUT_DATA) ? i_clk : 0;

assign o_address = write_wait_counter[5:0] + (row_addr * 64);

endmodule
