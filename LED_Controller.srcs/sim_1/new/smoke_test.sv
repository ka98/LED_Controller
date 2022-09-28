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
// Dependencies: negedge
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module smoke_test(
    output var o_rpio_04,
    output var o_rpio_05,
    output var o_rpio_06,
    output var o_rpio_12,
    output var o_rpio_13,
    output var o_rpio_16,
    output var o_rpio_17,
    output var o_rpio_20,
    output var o_rpio_21,
    output var o_rpio_22,
    output var o_rpio_23,
    output var o_rpio_24,
    output var o_rpio_26,
    output var o_rpio_27,

    output var [3:0] o_led

);

localparam period = 8.0; //125 Mhz
logic clk = 0;
tri tri_clk;
logic reset;

always begin : clock_generation
    clk = ~clk;
    #(period / 2);
end

assign tri_clk = clk;

tri [14:0]b_DDR_addr = '0;
tri [2:0]b_DDR_ba = '0;
tri b_DDR_cas_n = '0;
tri b_DDR_ck_n = '0;
tri b_DDR_ck_p = '0;
tri b_DDR_cke = '0;
tri b_DDR_cs_n = '0;
tri [3:0]b_DDR_dm = '0;
tri [31:0]b_DDR_dq = '0;
tri [3:0]b_DDR_dqs_n = '0;
tri [3:0]b_DDR_dqs_p = '0;
tri b_DDR_odt = '0;
tri b_DDR_ras_n = '0;
tri b_DDR_reset_n = '0;
tri b_DDR_we_n = '0;
tri b_FIXED_IO_ddr_vrn = '0;
tri b_FIXED_IO_ddr_vrp = '0;
tri [53:0]b_FIXED_IO_mio = '0;
tri b_FIXED_IO_ps_porb = '0;
tri b_FIXED_IO_ps_srstb = '0;

top_design u_top_design(
    .i_sysclk            (clk                 ),
    .i_btn               ({reset, 0}       ),
    .o_rpio_04           (o_rpio_04           ),
    .o_rpio_05           (o_rpio_05           ),
    .o_rpio_06           (o_rpio_06           ),
    .o_rpio_12           (o_rpio_12           ),
    .o_rpio_13           (o_rpio_13           ),
    .o_rpio_16           (o_rpio_16           ),
    .o_rpio_17           (o_rpio_17           ),
    .o_rpio_20           (o_rpio_20           ),
    .o_rpio_21           (o_rpio_21           ),
    .o_rpio_22           (o_rpio_22           ),
    .o_rpio_23           (o_rpio_23           ),
    .o_rpio_24           (o_rpio_24           ),
    .o_rpio_26           (o_rpio_26           ),
    .o_rpio_27           (o_rpio_27           ),
    .o_led               (o_led               )
);


initial begin
    reset = 1'b1;
    #period
    reset = 1'b0;
end



endmodule
