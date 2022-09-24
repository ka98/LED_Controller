`default_nettype none
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/03/2022 08:31:39 PM
// Design Name: 
// Module Name: Top_design
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


module top_design(

    input var i_sysclk,
    input var [1:0] i_btn,

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

    output var [1:0] o_led,

    //PS

    inout tri [14:0]b_DDR_addr,
    inout tri [2:0]b_DDR_ba,
    inout tri b_DDR_cas_n,
    inout tri b_DDR_ck_n,
    inout tri b_DDR_ck_p,
    inout tri b_DDR_cke,
    inout tri b_DDR_cs_n,
    inout tri [3:0]b_DDR_dm,
    inout tri [31:0]b_DDR_dq,
    inout tri [3:0]b_DDR_dqs_n,
    inout tri [3:0]b_DDR_dqs_p,
    inout tri b_DDR_odt,
    inout tri b_DDR_ras_n,
    inout tri b_DDR_reset_n,
    inout tri b_DDR_we_n,
    inout tri b_FIXED_IO_ddr_vrn,
    inout tri b_FIXED_IO_ddr_vrp,
    inout tri [53:0]b_FIXED_IO_mio,
    inout tri b_FIXED_IO_ps_clk,
    inout tri b_FIXED_IO_ps_porb,
    inout tri b_FIXED_IO_ps_srstb


    );

tri reset;
assign reset = i_btn[0];

tri clk_50Mhz;
tri clk_reset;

assign o_led[0] = reset;
assign o_led[1] = clk_50Mhz;
assign o_led[2] = clk_reset;

tri red0;
tri red1;
tri green0;
tri green1;
tri blue0;
tri blue1;

tri output_R0;    
tri output_R1;
tri output_G0;
tri output_G1;
tri output_B0;
tri output_B1;
tri output_BLANK;
tri output_clk;
tri output_lat;
tri output_A;
tri output_B;
tri output_C;
tri output_D;
tri output_E;

tri reset_to_display;
assign reset_to_display = reset;

to_display u_to_display(
    .i_clk (clk_50Mhz),
    .i_reset (reset_to_display),
    .i_R0  (red0     ),
    .i_R1  (red1     ),
    .i_G0  (green0   ),
    .i_G1  (green1   ),
    .i_B0  (blue0    ),
    .i_B1  (blue1    ),
    .o_R0  (output_R0),
    .o_R1  (output_R1),
    .o_G0  (output_G0),
    .o_G1  (output_G1),
    .o_B0  (output_B0),
    .o_B1  (output_B1),
    .o_BLANK  (output_BLANK),
    .o_clk (output_clk),
    .o_lat (output_lat),
    .o_A   (output_A),
    .o_B   (output_B),
    .o_C   (output_C),
    .o_D   (output_D),
    .o_E   (output_E)
);

assign o_rpio_05 = output_R0;    
assign o_rpio_12 = output_R1;
assign o_rpio_13 = output_G0;
assign o_rpio_16 = output_G1;
assign o_rpio_06 = output_B0;
assign o_rpio_23 = output_B1;
assign o_rpio_04 = output_BLANK;
assign o_rpio_17 = output_clk;
assign o_rpio_21 = output_lat;
assign o_rpio_22 = output_A;
assign o_rpio_26 = output_B;
assign o_rpio_27 = output_C;
assign o_rpio_20 = output_D;
assign o_rpio_24 = output_E;


//****************-VIO Declaration-******************

generic_io u_generic_io(
    .clk        (clk_50Mhz    ),
    .probe_in0  (output_R0    ),
    .probe_in1  (output_R1    ),
    .probe_in2  (output_G0    ),
    .probe_in3  (output_G1    ),
    .probe_in4  (output_B0    ),
    .probe_in5  (output_B1    ),
    .probe_in6  (output_BLANK ),
    .probe_in7  (output_clk   ),
    .probe_in8  (output_lat   ),
    .probe_in9  (output_A     ),
    .probe_in10 (output_B     ),
    .probe_in11 (output_C     ),
    .probe_in12 (output_D     ),
    .probe_in13 (output_E     )
);

color_vio u_color_vio(
    .clk        (clk_50Mhz ),
    .probe_out0 (red0 ),
    .probe_out1 (red1 ),
    .probe_out2 (green0 ),
    .probe_out3 (green1 ),
    .probe_out4 (blue0 ),
    .probe_out5 (blue1 )
);

design_1_wrapper u_design_1_wrapper(
    .DDR_addr          (b_DDR_addr          ),
    .DDR_ba            (b_DDR_ba            ),
    .DDR_cas_n         (b_DDR_cas_n         ),
    .DDR_ck_n          (b_DDR_ck_n          ),
    .DDR_ck_p          (b_DDR_ck_p          ),
    .DDR_cke           (b_DDR_cke           ),
    .DDR_cs_n          (b_DDR_cs_n          ),
    .DDR_dm            (b_DDR_dm            ),
    .DDR_dq            (b_DDR_dq            ),
    .DDR_dqs_n         (b_DDR_dqs_n         ),
    .DDR_dqs_p         (b_DDR_dqs_p         ),
    .DDR_odt           (b_DDR_odt           ),
    .DDR_ras_n         (b_DDR_ras_n         ),
    .DDR_reset_n       (b_DDR_reset_n       ),
    .DDR_we_n          (b_DDR_we_n          ),
    .FCLK_CLK0_0       (clk_50Mhz           ),
    .FCLK_RESET0_N_0   (clk_reset           ),
    .FIXED_IO_ddr_vrn  (b_FIXED_IO_ddr_vrn  ),
    .FIXED_IO_ddr_vrp  (b_FIXED_IO_ddr_vrp  ),
    .FIXED_IO_mio      (b_FIXED_IO_mio      ),
    .FIXED_IO_ps_clk   (b_FIXED_IO_ps_clk   ),
    .FIXED_IO_ps_porb  (b_FIXED_IO_ps_porb  ),
    .FIXED_IO_ps_srstb (b_FIXED_IO_ps_srstb )
);


endmodule
