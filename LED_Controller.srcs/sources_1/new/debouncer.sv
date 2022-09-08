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

module debouncer(

    input var i_clk, //125 MHZ
    input var i_rst,
    input var i_input,

    output var o_output

);

var int unsigned SAMPLES = 6250000; //50 ms when using a 125Mhz clock

int unsigned counter = 0;
logic output_state = 0;

always_ff @(posedge i_clk) begin : some_name

    if (i_rst) begin
        output_state <= 0;
        counter <= 0;
    end
    else begin
        if (i_input != output_state) begin
            if (counter < 6250000) begin
                output_state <= output_state;
                counter <= counter + 1;
            end else begin
                output_state <= i_input;
                counter <= 0;
            end
        end else begin
            output_state <= output_state;
            counter <= 0;
        end 
    end
end

assign o_output = output_state;

endmodule