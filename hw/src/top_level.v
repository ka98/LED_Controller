module top_level (
    input axi_clk,
    input axi_rst,

    input [63:0] axi4l_s_awaddr,
    input [2:0] axi4l_s_awprot,
    input axi4l_s_awvalid,
    output reg axi4l_s_awready,

    input [31:0] axi4l_s_wdata,
    input [3:0] axi4l_s_wstrb,
    input axi4l_s_wvalid,
    output reg axi4l_s_wready,

    output [1:0] axi4l_s_bresp,
    output reg axi4l_s_bvalid,
    input axi4l_s_bready,

    input [63:0] axi4l_s_araddr,
    input [2:0] axi4l_s_arprot,
    input axi4l_s_arvalid,
    output reg axi4l_s_arready,

    output [31:0] axi4l_s_rdata,
    output [1:0] axi4l_s_rresp,
    output reg axi4l_s_rvalid,
    input axi4l_s_rready,

    output o_R0,
    output o_R1,
    output o_G0,
    output o_G1,
    output o_B0,
    output o_B1,

    output o_BLANK,
    output o_clk,
    output o_lat,

    output o_A,
    output o_B,
    output o_C,
    output o_D,
    output o_E
);

wire [12:0] local_addr;
wire [31:0] local_wr_data;
wire [31:0] local_rd_data;
wire local_wr;

wire [23:0] ram_async_data;
wire [10:0] ram_async_addr;

axi4_lite_slave 
u_axi4_lite_slave(
    .axi_clk         (axi_clk         ),
    .axi_rst         (axi_rst         ),
    .axi4l_s_awaddr  (axi4l_s_awaddr  ),
    .axi4l_s_awprot  (axi4l_s_awprot  ),
    .axi4l_s_awvalid (axi4l_s_awvalid ),
    .axi4l_s_awready (axi4l_s_awready ),
    .axi4l_s_wdata   (axi4l_s_wdata   ),
    .axi4l_s_wstrb   (axi4l_s_wstrb   ),
    .axi4l_s_wvalid  (axi4l_s_wvalid  ),
    .axi4l_s_wready  (axi4l_s_wready  ),
    .axi4l_s_bresp   (axi4l_s_bresp   ),
    .axi4l_s_bvalid  (axi4l_s_bvalid  ),
    .axi4l_s_bready  (axi4l_s_bready  ),
    .axi4l_s_araddr  (axi4l_s_araddr  ),
    .axi4l_s_arprot  (axi4l_s_arprot  ),
    .axi4l_s_arvalid (axi4l_s_arvalid ),
    .axi4l_s_arready (axi4l_s_arready ),
    .axi4l_s_rdata   (axi4l_s_rdata   ),
    .axi4l_s_rresp   (axi4l_s_rresp   ),
    .axi4l_s_rvalid  (axi4l_s_rvalid  ),
    .axi4l_s_rready  (axi4l_s_rready  ),
    .local_addr      (local_addr      ),
    .local_wr_data   (local_wr_data   ),
    .local_rd_data   (local_rd_data   ),
    .local_wr        (local_wr        )
);

rams_dist u_rams_dist(
    .clk  (axi_clk ),
    .we   (local_wr),
    .a    (local_addr[12:2]),
    .dpra (ram_async_addr ),
    .di   (local_wr_data),
    .spo  (local_rd_data),
    .dpo  (ram_async_data)
);

to_display 
u_to_display(
    .i_clk     (axi_clk),
    .i_reset   (axi_rst),
    .i_data0   (ram_async_data),
    .i_data1   (ram_async_data),
    .o_R0      (o_R0      ),
    .o_R1      (o_R1      ),
    .o_G0      (o_G0      ),
    .o_G1      (o_G1      ),
    .o_B0      (o_B0      ),
    .o_B1      (o_B1      ),
    .o_BLANK   (o_BLANK   ),
    .o_clk     (o_clk     ),
    .o_lat     (o_lat     ),
    .o_A       (o_A       ),
    .o_B       (o_B       ),
    .o_C       (o_C       ),
    .o_D       (o_D       ),
    .o_E       (o_E       ),
    .o_address (ram_async_addr )
);



endmodule