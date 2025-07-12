module op_shr_64(input [63:0] Ain, Bin, output [63:0] Zout);
    assign Zout = Ain >> Bin;
endmodule

module op_shr_32(input [31:0] Ain, Bin, output [31:0] Zout);
    assign Zout = Ain >> Bin;
endmodule