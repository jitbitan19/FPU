module SeriesRLC #(parameter p = 28, q=20, N=27)//1 sign bit, 11 integer bits, 20 fractional bits
    (input Clk, input Clk100,
    input DCON,
    input HeatON,
    input G0, input G1,
    output CurrentZCD,
    output signed [15:0] PowerPU,
    output signed [15:0] MFCurrentPU,
    output signed [15:0] TankVoltPU,
    input [N-1:0] Frequency,
    
    input ChipSelect, 
    input SCLK,
    output SDOvdc, output SDOidc, output SDOipeak, output SDOvcpeak
    );
    
    //Manually adjust the followings
    localparam m = 2**q;
    
    localparam R = 35e-3; //Resistance in Ohm  
    localparam L = 15e-6; //Inductance in Henry
    localparam C = 300e-6; //Capacitance in Farad
    localparam T = 1e-7; //Sampling time in Second
    
    localparam a = 9986; //$rtoi(m*T/R/C);
    localparam b = 245; //$rtoi(m*T*R/L);
    // $rtoi() works for Arty A7-35 with vivado 23.2, but doesn't work for Zynq with vivado 2018.2
    //manually adjust the above
    
    wire signed [p+q-1:0] v;
    assign v = (G1-G0)*128*m*DCON;
    
    reg signed [p+q-1:0] w = 0;
    reg signed [p+q-1:0] ipeak = 0;
    reg signed [p+q-1:0] vcpeak = 0;
    
    reg signed [p+q-1:0] ir = 0; // actually i represents i*R/Vc_peak
    
    reg signed [p+q-1:0] vprev = 0;
    reg signed [p+q-1:0] vc = 0; // actually vc represents vc/Vc_peak
    reg signed [p+q+N-1:0] irint = 0;
    reg signed [p+q-1:0] irp = 0, vcp = 0;
    
    always @(posedge Clk) begin
        if(DCON & HeatON) begin
            //RLC simulation begin
            vc <= vc + ((ir*a)>>>q);
            ir <= ir + (((v-vc-ir)*b)>>>q);
            //RLC simulation end
            
            //For power estimation begin
            if(vprev<0 && v>0) begin
                w = (((irint*Frequency)>>>(N))*v)>>>q;
                irint = 0;
            end else if (v>0) begin
                irint = irint+ir;
            end else begin
                irint = irint-ir;
            end
            //For power estimation end
            
            //For ipeak estimation begin
            if(vprev<0 && v>0) begin
                ipeak = irp;
                irp = 0;
            end else if (ir>irp) begin
                irp = ir;
            end
            //For ipeak estimation end
            
            //For vcpeak estimation begin
            if(vprev<0 && v>0) begin
                vcpeak = vcp;
                vcp = 0;
            end else if (vc>vcp) begin
                vcp = vc;
            end
            //For vcpeak estimation end
        end
        else begin
            vc <= 0;
            vcp <= 0;
            vcpeak <= 0;
            ir <= 0;
            irp <= 0;
            ipeak <= 0;
            irint <= 0;
            w <= 0;
        end
        vprev <= v;
    end    
    assign CurrentZCD = ~ir[p+q-1];
    
    assign PowerPU = ((w*3'b101)>>>(q+1)); //12500W/.035 = 16'b0111111111111111111 = 125%
    assign MFCurrentPU = ((ipeak*8'b10011100)>>>q); //210A/.035 = 6kA  ~= 16'b0111111111111111111 = 125%
    assign TankVoltPU = (vcpeak*5'b11011>>>(q)); //1200V  ~= 16'b0111111111111111111 = 125%
    /////////////////////////
    //SPI interfaces
    SPI_Client spiVdc(.Clk100(Clk100), .Data(DCON*16'b0111111111111111), .CS(ChipSelect), .SCLK(SCLK),.SDO(SDOvdc));
    SPI_Client spiIdc(.Clk100(Clk100), .Data(PowerPU), .CS(ChipSelect), .SCLK(SCLK),.SDO(SDOidc));
    SPI_Client spiIpeak(.Clk100(Clk100), .Data(MFCurrentPU), .CS(ChipSelect), .SCLK(SCLK),.SDO(SDOipeak));
    SPI_Client spiVcpeak(.Clk100(Clk100), .Data(TankVoltPU), .CS(ChipSelect), .SCLK(SCLK),.SDO(SDOvcpeak));
    
    
endmodule