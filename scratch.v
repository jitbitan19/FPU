// module tff (
//     output reg  q,
//     output      qn,
//     input       t, clk, rst
// );
//     always @(posedge clk) begin
//         if(!rst) q <= 0;
//         else begin
//             if(t == 1'b1) q <= ~q;
//             else  q <= q;
//         end
//     end
//     assign qn = ~q;
// endmodule

// module sync_counter (
//     output [3:0]    out,
//     input           clk, rst, cnt
// );
    
//     wire i0,  i1,  i2,  i3;
//     wire q0,  q1,  q2,  q3;
//     wire q0n, q1n, q2n, q3n;

//     assign i0 = cnt;
//     assign i1 = i0 & q0;
//     assign i2 = i1 & q1;
//     assign i3 = i2 & q2;

//     tff u0 (
//         .clk(clk),
//         .rst(rst),
//         .t  (i0),
//         .q  (q0),
//         .qn (q0n)
//     );
//     tff u1 (
//         .clk(clk),
//         .rst(rst),
//         .t  (i1),
//         .q  (q1),
//         .qn (q1n)
//     );
//     tff u2 (
//         .clk(clk),
//         .rst(rst),
//         .t  (i2),
//         .q  (q2),
//         .qn (q2n)
//     );
//     tff u3 (
//         .clk(clk),
//         .rst(rst),
//         .t  (i3),
//         .q  (q3),
//         .qn (q3n)
//     );

//     assign out = {q3,q2,q1,q0};
// endmodule

// module tb_sync_counter;
//     reg tb_clk, tb_rst, tb_cnt;
//     wire [3:0]  tb_out;
    
//     initial {tb_clk, tb_rst, tb_cnt} = 3'b0;
//     initial begin
//         #10 tb_rst = 1;
//         #20 tb_cnt = 1;
//         #100 tb_cnt = 0;
//     end
//     always #5 tb_clk = ~tb_clk;
//     initial #500 $finish;
//     initial begin
//         $dumpfile("build/output.vcd");
//         $dumpvars(0, tb_sync_counter);
//         $monitor("%d, clk=%b, rst=%b, cnt=%b, out=%b", $time, tb_clk, tb_rst, tb_cnt, tb_out);
//     end

//     sync_counter u1(
//         .clk(tb_clk),
//         .rst(tb_rst),
//         .cnt(tb_cnt),
//         .out(tb_out)
//     );
// endmodule

// module lshift_reg (input 						clk,				// Clock input
//                    input 						rstn,				// Active low reset input
//                    input [7:0] 			load_val, 	// Load value
//                    input 						load_en, 		// Load enable
//                    output reg [7:0] op); 				// Output register value

// 	 // At posedge of clock, if reset is low set output to 0
// 	 // If reset is high, load new value to op if load_en=1
// 	 // If reset is high, and load_en=0 shift register to left
// 	 always @ (posedge clk) begin
// 	    if (!rstn) begin
// 	      op <= 0;
// 	    end else begin
// 	    	if (load_en) begin
// 	      	op <= load_val;
// 	      end else begin
// 	        op[0] <= op[7];
// 	        op[1] <= op[0];
// 	        op[2] <= op[1];
// 	        op[3] <= op[2];
// 	        op[4] <= op[3];
// 	        op[5] <= op[4];
// 	        op[6] <= op[5];
// 	        op[7] <= op[6];
// 	      end
// 	    end
// 	  end
// endmodule