`include "scratch.v"
`default_nettype none

module tb_scratch;
reg clk;
reg rst_n;

scratch u0
(
    .rst_n (rst_n),
    .clk (clk),
);

localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) clk=~clk;

initial begin
    $dumpfile("tb_scratch.vcd");
    $dumpvars(0, tb_scratch);
end

initial begin
    #1 rst_n<=1'bx;clk<=1'bx;
    #(CLK_PERIOD*3) rst_n<=1;
    #(CLK_PERIOD*3) rst_n<=0;clk<=0;
    repeat(5) @(posedge clk);
    rst_n<=1;
    @(posedge clk);
    repeat(2) @(posedge clk);
    $finish(2);
end

endmodule
`default_nettype wire