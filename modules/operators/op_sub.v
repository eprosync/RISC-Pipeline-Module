module op_sub_64(input [63:0] Ain, Bin, output [63:0] Zout);
    wire [63:0] negated;
    wire add_cout_void;
    op_neg_64 invert(.Ain(Bin), .Zout(negated));
    op_add_64 subtract(.Ain(Ain), .Bin(negated), .Cin(64'b0), .Zout(Zout), .Cout(add_cout_void));
endmodule

module op_sub_32(input [31:0] Ain, Bin, output [31:0] Zout);
    wire [31:0] negated;
    wire add_cout_void;
    op_neg_32 invert(.Ain(Bin), .Zout(negated));
    op_add_32 subtract(.Ain(Ain), .Bin(negated), .Cin(32'b0), .Zout(Zout), .Cout(add_cout_void));
endmodule