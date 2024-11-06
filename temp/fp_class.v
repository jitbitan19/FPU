`timescale 1ns / 1ps

module fp_class(
	exp, man, nan, inf, zero, dnorm, norm, // output
	f // input
);
	parameter N_EXP = 11;
	parameter N_MAN = 52;
	parameter BIAS = ((1 << (N_EXP-1)));
	parameter log_N_MAN = $clog2(N_EXP+1);
	parameter EMIN = (1-BIAS);
	parameter EMAX = BIAS;


	input			[N_EXP+N_MAN : 0] f;
	output signed 	[N_EXP+1 : 0]	exp;
	reg signed 		[N_EXP+1 : 0]	exp;
	output reg 		[N_MAN : 0]		man;
	output 							nan, inf, zero, dnorm, norm;

	wire exp1, exp0, man0;
	assign exp1 =  & f[N_EXP+N_MAN-1 : N_MAN];
	assign exp0 = ~| f[N_EXP+N_MAN-1 : N_MAN];
	assign man0 = ~| f[N_MAN-1 : 0];


    assign zero  =  exp0 &  man0;
    assign inf   =  exp1 &  man0;
    assign dnorm =  exp0 & ~man0;
    assign nan   =  exp1 & ~man0;
    assign norm  = ~exp1 & ~exp0;

	reg [N_MAN : 0] 	mask = ~0;
	reg [log_N_MAN-1:0]	sh;
    
    always @(*)
		begin
			exp = f[N_EXP+N_MAN-1 : N_MAN];
			man = f[N_MAN-1 : 0];
			sh = 0;

			if (norm) begin
				exp = f[N_EXP+N_MAN-1 : N_MAN] - BIAS;
				man = {1'b1, f[N_MAN-1 : 0]};
			end
			else if (dnorm) begin
				for (integer i = (1<<(log_N_MAN-1)); i > 0; i = i >> 1) begin
					if ((exp & (mask << (N_MAN+1 - i))) == 0) begin
						exp = exp << i;
						sh = sh | i;
					end
				end
				exp = EMIN - sh;
			end
		end
endmodule