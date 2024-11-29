`timescale 1ns / 1ps
`include "fp_class.v"

module fp_mul (
    p, nan, inf, zero, dnorm, norm, // output
    a, b // input 
);
    // parameter N_EXP     = 11;
	// parameter N_MAN     = 52;
	// parameter BIAS      = (1 << (N_EXP-1));
	// parameter log_N_MAN = $clog2(N_MAN+1);
	// parameter EMIN      = 1-BIAS;
	// parameter EMAX      = BIAS;

    parameter N_EXP     = 11;
	parameter N_MAN     = 52;
	parameter BIAS      = (1 << (N_EXP-1));
	parameter log_N_MAN = $clog2(N_MAN+1);
	parameter EMIN      = 1-BIAS;
	parameter EMAX      = BIAS;

    output  [N_EXP+N_MAN : 0]   p;
    output reg                  nan, inf, zero, dnorm, norm;
    input   [N_EXP+N_MAN : 0]   a, b;

    wire signed [N_EXP+1 : 0]    aexp, bexp;
    wire        [N_MAN : 0]      aman, bman;

    reg signed  [N_EXP+1 : 0]    pexp, t1exp, t2exp;
    reg         [N_MAN : 0]      pman, tman;
    reg         [N_EXP+N_MAN : 0] pt;
    reg ps;
    wire [2*N_MAN+1 : 0] res;

    wire anan, ainf, azero, adnorm, anorm;
    wire bnan, binf, bzero, bdnorm, bnorm;

    fp_class #(N_EXP, N_MAN) u1 (
        .exp    (aexp),
        .man    (aman),
        .nan    (anan),
        .inf    (ainf),
        .zero   (azero),
        .dnorm  (adnorm),
        .norm   (anorm),
        .f      (a)
    );

    fp_class #(N_EXP, N_MAN) u2 (
        .exp    (bexp),
        .man    (bman),
        .nan    (bnan),
        .inf    (binf),
        .zero   (bzero),
        .dnorm  (bdnorm),
        .norm   (bnorm),
        .f      (b)
    );

    assign res = aman * bman;

    always @(*) begin
        ps = a[N_EXP+N_MAN] ^ b[N_EXP+N_MAN];
        pt = {ps, {N_EXP{1'b1}}, 1'b0, {N_MAN-1{1'b1}}};
        {nan, inf, zero, dnorm, norm} = 5'b0;

        if((anan | bnan) == 1'b1) begin
            nan = 1'b1;
        end
        else if((ainf | binf) == 1'b1) begin
            if((azero | bzero) == 1'b1) begin
                nan = 1'b1;
            end
            else begin
                pt = {ps, {N_EXP{1'b1}}, {N_MAN{1'b0}}};
                inf = 1'b1;
            end
        end
        else if(((azero | bzero) == 1'b1)||((adnorm & bdnorm) == 1'b1)) begin
            pt = {ps, {N_EXP+N_MAN {1'b0}}};
            zero = 1'b1;
        end
        else begin
            t1exp = aexp + bexp;

            if(res[2*N_MAN+1] == 1'b1) begin
                tman = res[2*N_MAN+1 : N_MAN+1];
                t2exp = t1exp + 1;
            end
            else begin
                tman = res[2*N_MAN : N_MAN];
                t2exp = t1exp;
            end

            if (t2exp < (EMIN-N_MAN)) begin // smaller than dnorm
                pt = {ps, {N_EXP+N_MAN{1'b0}}};
                zero = 1'b1;
            end
            else if(t2exp < EMIN) begin // dnorm
                pman = tman >> (EMIN - t2exp);
                pt = {ps, {N_EXP{1'b0}}, pman[N_MAN-1 : 0]};
                inf = 1'b1;
            end
            else if(t2exp > EMAX) begin // inf
                pt = {ps, {N_EXP{1'b1}}, {N_MAN{1'b0}}};
                inf = 1'b1;
            end
            else begin // norm
                pexp = t2exp + BIAS;
                pman = tman;
                pt = {ps, pexp[N_EXP-1 : 0], pman[N_MAN-1 : 0]};
                norm = 1'b1;
            end
        end
    end

    assign p = pt;

endmodule