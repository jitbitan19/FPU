`timescale 1ns / 1ps
`include "fp_class.v"

module fp_mul (
    p, nan, inf, zero, dnorm, norm, // output
    a, b // input 
);
    parameter NEXP = 11;
	parameter NMAN = 52;
	parameter bias = ((1 << (NEXP-1)));
	parameter log_NMAN = $clog2(NEXP+1);
	parameter EMIN = (1-bias);
	parameter EMAX = bias;

    output  [NEXP+NMAN : 0] p;
    output reg              nan, inf, zero, dnorm, norm;
    input   [NEXP+NMAN : 0] a, b;

    wire signed [NEXP+1 : 0]    aexp, bexp;
    wire        [NMAN : 0]      aman, bman;

    reg signed  [NEXP+1 : 0]    pexp, t1exp, t2exp;
    reg         [NMAN : 0]      pman, tman;
    reg         [NEXP+NMAN : 0] pt;
    reg ps;
    wire [2*NMAN+1 : 0] res;

    wire anan, ainf, azero, adnorm, anorm;
    wire bnan, binf, bzero, bdnorm, bnorm;

    fp_class #(NEXP, NMAN) u1 (
        .exp    (aexp),
        .man    (aman),
        .nan    (anan),
        .inf    (ainf),
        .zero   (azero),
        .dnorm  (adnorm),
        .norm   (anorm),
        .f      (a)
    );

    fp_class #(NEXP, NMAN) u2 (
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
        ps = a[NEXP+NMAN] ^ b[NEXP+NMAN];
        pt = {ps, {NEXP{1'b1}}, 1'b0, {NMAN-1{1'b1}}};
        nan = 1'b1;

        if((anan | bnan) == 1'b1) begin
            nan = 1'b1;
        end
        else if((ainf | binf) == 1'b1) begin
            if((azero | bzero) == 1'b1) begin
                nan = 1'b1;
            end
            else begin
                pt = {ps, {NEXP{1'b1}}, {NMAN{1'b0}}};
                inf = 1'b1;
            end
        end
        else if(((azero | bzero) == 1'b1)||((adnorm & bdnorm) == 1'b1)) begin
            pt = {ps, {NEXP+NMAN {1'b0}}};
            zero = 1'b1;
        end
        else begin
            t1exp = aexp + bexp;

            if(res[2*NMAN+1] == 1'b1) begin
                tman = res[2*NMAN+1 : NMAN+1];
                t2exp = t1exp + 1;
            end
            else begin
                tman = res[2*NMAN : NMAN];
                t2exp = t1exp;
            end

            if (t2exp < (EMIN-NMAN)) begin // smaller than dnorm
                pt = {ps, {NEXP+NMAN{1'b0}}};
                zero = 1'b1;
            end
            else if(t2exp < EMIN) begin // dnorm
                pman = tman >> (EMIN - t2exp);
                pt = {ps, {NEXP{1'b0}}, pman[NMAN-1 : 0]};
                inf = 1;
            end
            else if(t2exp > EMAX) begin // inf
                pt = {ps, {NEXP{1'b1}}, {NMAN{1'b0}}};
                inf = 1;
            end
            else begin // norm
                pexp = t2exp + bias;
                pman = tman;
                pt = {ps, pexp[NEXP-1 : 0], pman[NMAN-1 : 0]};
                norm = 1'b1;
            end
        end
    end

    assign p = pt;

endmodule