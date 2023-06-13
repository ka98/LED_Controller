// Dual-Port RAM with Asynchronous Read (Distributed RAM)
// File: rams_dist.v

module rams_dist (clk, we, a, dpra, di, spo, dpo);
input clk;
input we;
input [10:0] a;
input [10:0] dpra;
input [23:0] di;
output [23:0] spo;
output [23:0] dpo;
reg [23:0] ram [2047:0];
always @(posedge clk)
    begin
    if (we)
        ram[a] <= di;
    end
assign spo = ram[a];
assign dpo = ram[dpra];
endmodule 