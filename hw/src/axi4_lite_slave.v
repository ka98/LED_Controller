module axi4_lite_slave (
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

    output [G_BASE_ADDR_WIDTH-1 : 0] local_addr,
    output [31:0] local_wr_data,
    output [31:0] local_rd_data,
    output local_wr
);
parameter G_BASE_ADDR = 32'h40000000;
parameter G_BASE_ADDR_SIZE = 8192*2;
parameter G_BASE_ADDR_WIDTH = 14;

localparam [2:0]
    S_IDLE = 3'b000,
    S_WRITE = 3'b001,
    S_WRITE_ACK = 3'b010,
    S_READ = 3'b011,
    S_READ_ACK = 3'b100;

reg [2:0] state = S_IDLE;
reg [63:0] i_addr = 0;

wire aw_addr_range_match;
wire ar_addr_range_match;

always @(posedge axi_clk) begin
    if (axi_rst == 1) begin
        state <= S_IDLE;
        i_addr <= 0;
        axi4l_s_awready <= 0;
        axi4l_s_wready <= 0;
        axi4l_s_arready <= 0;
    end
    else begin
        case (state)
            S_IDLE: begin
                axi4l_s_rvalid <= 0;

                if (axi4l_s_awvalid && aw_addr_range_match) begin
                    i_addr <= axi4l_s_awaddr;
                    axi4l_s_awready <= 1;
                    axi4l_s_wready <= 1;
                    state <= S_WRITE;
                end
                else if (axi4l_s_arvalid && ar_addr_range_match) begin
                    i_addr <= axi4l_s_araddr;
                    axi4l_s_arready <= 1;
                    state <= S_READ;
                end
            end
            S_WRITE: begin
                axi4l_s_awready <= 0;
                if (axi4l_s_wvalid) begin
                    axi4l_s_wready <= 0;
                    axi4l_s_bvalid <= 1;
                    state <= S_WRITE_ACK;
                end
            end

            S_WRITE_ACK: begin
                if (axi4l_s_bready) begin
                    axi4l_s_bvalid <= 0;
                    state <= S_IDLE;
                end
            end

            S_READ: begin
                axi4l_s_arready <= 0;
                axi4l_s_rvalid <= 1;
                state <= S_READ_ACK;
            end

            S_READ_ACK: begin
                if (axi4l_s_rready) begin
                    axi4l_s_rvalid <= 0;
                    state <= S_IDLE;
                end
            end

            default: begin
                state <= S_IDLE;
                axi4l_s_awready <= 0;
                axi4l_s_wready <= 0;
                axi4l_s_arready <= 0;
            end
        endcase
    end
end

    assign aw_addr_range_match = ((axi4l_s_awaddr >= G_BASE_ADDR && axi4l_s_awaddr < (G_BASE_ADDR + G_BASE_ADDR_SIZE)) ? 1 : 0);
    assign ar_addr_range_match = ((axi4l_s_araddr >= G_BASE_ADDR && axi4l_s_araddr < (G_BASE_ADDR + G_BASE_ADDR_SIZE)) ? 1 : 0);

    assign local_addr = i_addr;
    assign local_wr_data = axi4l_s_wdata;
    assign local_wr = state == S_WRITE ? 1 : 0;

    assign axi4l_s_bresp = 0;
    assign axi4l_s_rresp = 0;
    assign axi4l_s_rdata = local_rd_data;
    
endmodule