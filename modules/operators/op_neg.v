module op_neg_64(input [63:0] Ain, output [63:0] Zout);
    wire [63:0] temp;

    op_not_64 invert_op(.Ain(Ain), .Zout(temp));
    op_add_64 twos_comp(.Ain(temp), .Bin(64'b0), .Cin(1'd1), .Zout(Zout));
endmodule

module op_neg_32(input [31:0] Ain, output [31:0] Zout);
    wire [31:0] temp;

    op_not_32 invert_op(.Ain(Ain), .Zout(temp));
    op_add_32 twos_comp(.Ain(temp), .Bin(32'b0), .Cin(1'd1), .Zout(Zout));
endmodule