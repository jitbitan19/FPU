`timescale 1ns / 1ps
`include "fp_mul.v"

module tb_fp_mul;

    parameter NEXP = 11;
    parameter NSIG = 52;

    reg  [NEXP+NSIG : 0]    a, b;
    wire [NEXP+NSIG : 0]    p;
    wire                    pnan, pinf, pzero, pdnorm, pnorm;

    initial #100 $finish;
    initial $monitor ("a (%x) * b(%x) = p (%x) of type (%b %b %b %b %b)", a, b, p, pnan, pinf, pzero, pdnorm, pnorm);

    // initial begin
    //     #10 assign a = 64'b1100000000101111000000000000000000000000000000000000000000000000;
    //         assign b = 64'b0100000000011000110011001100110011001100110011001100110011001101;
    // end

    initial begin
        assign a = {1'b0, {NEXP{1'b0}}, {NSIG{1'b1}}};
        assign b = {64{1'b0}};

        #10
        assign a = 64'b0100000000010110110000101000111101011100001010001111010111000011;
        assign b = 64'b0100000000100100100000110001001001101110100101111000110101010000;
    end


    initial begin
        $dumpfile ("tb_fp_class.vcd");
        $dumpvars (0, tb_fp_mul);
    end

    fp_mul # (NEXP, NSIG) u (
        .a      (a),
        .b      (b),
        .p      (p),
        .nan    (pnan),
        .inf    (pinf),
        .zero   (pzero),
        .dnorm  (pdnorm),
        .norm   (pnorm)
    );
endmodule