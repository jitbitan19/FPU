`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module LLC #(parameter p = 28, q=20, N=27)//1 sign bit, 11 integer bits, 20 fractional bits
    (
        input Clk, input Clk100,
        input DCON,
        input HeatON,
        input G0, input G1
    );
    
    //Manually adjust the followings
    localparam m = 2**q;
    
    localparam C1 = 780e-6; //Capacitance in Farad
    localparam C2 = 780e-6; //Capacitance in Farad
    localparam L = 80e-6;   //Inductance in Henry
    localparam R = 50e-3;   //Resistance in Ohm  
    localparam T = 1e-7;    //Sampling time in Second
    
    localparam a = 2689; //$rtoi(m*T/(R*C1));
    localparam b = 2689; //$rtoi(m*T/(R*C2));
    localparam c = 66;   //$rtoi(m*T*R/L);
    localparam d = 44;   //$rtoi(m*T*R/Lb);
    // $rtoi() works for Arty A7-35 with vivado 23.2, but doesn't work for Zynq with vivado 2018.2
    //manually adjust the above
    
    wire signed [p+q-1:0] v;
    assign v = (G1-G0)*128*m*DCON;
    reg signed [p+q-1:0] vt = 0, v2 = 0, i1r = 0, i2r = 0, ir = 0;
    
    reg signed [p+q-1:0] w = 0;
    reg signed [p+q-1:0] ipeak = 0;
    reg signed [p+q-1:0] vcpeak = 0;
    
    reg signed [p+q-1:0] vprev = 0;
    
    reg signed [p+q+N-1:0] irint = 0;
    reg signed [p+q-1:0] irp = 0, vcp = 0;
    
    always @(posedge Clk) begin
        if(DCON & HeatON) begin
            //LLC simulation begin
            vt <= vt + ((i1r*a)>>>q);
            v2 <= v2 + ((i2r*b)>>>q);
            i2r <= i2r + (((vt-v2-i2r)*c)>>>q);
            i1r <= i1r - (((vt-v2-i2r)*c)>>>q) + (((v-vt)*d)>>>q);
            ir <= i1r + i2r;
            //LLC simulation end
            
        end
        else begin
            
        end
        vprev <= v;
    end    
endmodule


module TB_LLC;
    reg Clk = 0, Clk100 = 0, reset = 1;
    always #50 begin Clk <= ~Clk; end
    always #5 begin Clk100 <= ~Clk100; end
    
    reg G0 = 0, G1 = 0;
    always begin G0 <= 0; #500000 G0 <=1; #500000; end
    always begin G1 <= 1; #200000 G1 <=0; #500000 G1 <=1; #300000; end
    
    LLC llc1(.Clk(Clk), .Clk100(Clk100),
    .DCON(reset),
    .HeatON(reset),
    .G0(G0), .G1(G1)
    );

    initial begin
        $dumpfile("out.vcd");
        $dumpvars(0, TB_LLC);
    end
    initial #10000000 $finish;
endmodule
