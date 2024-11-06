module asdf (
    output  reg c,
    input       a, b
);
    c <= a&b;
endmodule

module tb_asdf
    reg ta, tb, tc;
    asdf u(tc, ta, tb);
    initial begin
        ta = 0;
        tb = 0;
        #10
        ta = 1;
        tb = 1;
    end
    initial #100 $finish;
endmodule