`default_nettype none
`timescale 1ns / 1ps

module test_write(

    input var i_clk, //125 MHZ
    input var i_rst,

    output var [11:0] o_address,
    output var [23:0] o_value,
    output var o_write_enable

);

logic [11:0] pixel_addr = 0;
integer counter = 0;
logic write_black = 0;
logic enable_write = 0;


always_ff @(posedge i_clk or posedge i_rst) begin : check_enable
    if (i_rst) begin
            counter = 0;
            enable_write = 0;
    end 
    else begin
        if (counter == 30000000 / 100000) begin // pixels ever 100 ms
            counter = 0;
            enable_write = 1;

        end
        else begin
            enable_write = 0;
            counter <= counter + 1;
        end
    end
end

always_ff @(posedge i_clk or posedge i_rst) begin : name

    if (i_rst) begin
        pixel_addr = 0;
        write_black = 0;
        o_write_enable = 0;
    end 
    else begin
        if (enable_write) begin
            o_write_enable = 1;
            if (pixel_addr == 4095) begin
                write_black = ~write_black;
                pixel_addr = 0;
            end
            if (write_black) begin
                o_value = 0;
            end else begin
                o_value = 24'hFFFFFF;
            end
            pixel_addr <= pixel_addr + 1;
        end
        else begin
            o_write_enable = 0;
        end
    end

end

assign o_address = pixel_addr;

endmodule
