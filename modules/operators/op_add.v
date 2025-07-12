module op_add_64(input [63:0] Ain, Bin, input wire Cin, output [63:0] Zout, output wire Cout);
	wire Cout1;

	op_add_32 OP1(.Ain(Ain[31:0]), .Bin(Bin[31:0]), .Cin(Cin), .Zout(Zout[31:0]), .Cout(Cout1));
	op_add_32 OP2(.Ain(Ain[63:32]), .Bin(Bin[63:32]), .Cin(Cout1), .Zout(Zout[63:32]), .Cout(Cout));
endmodule

module op_add_32(input [31:0] Ain, Bin, input wire Cin, output [31:0] Zout, output wire Cout);
	wire Cout1;

	op_add_16 OP1(.Ain(Ain[15:0]), .Bin(Bin[15:0]), .Cin(Cin), .Zout(Zout[15:0]), .Cout(Cout1));
	op_add_16 OP2(.Ain(Ain[31:16]), .Bin(Bin[31:16]), .Cin(Cout1), .Zout(Zout[31:16]), .Cout(Cout));
endmodule

module op_add_16(input [15:0] Ain, Bin, input wire Cin, output [15:0] Zout, output wire Cout);
	wire Cout1, Cout2, Cout3;

	op_add_4 OP1(.Ain(Ain[3:0]), .Bin(Bin[3:0]), .Cin(Cin), .Zout(Zout[3:0]), .Cout(Cout1));
	op_add_4 OP2(.Ain(Ain[7:4]), .Bin(Bin[7:4]), .Cin(Cout1), .Zout(Zout[7:4]), .Cout(Cout2));
	op_add_4 OP3(.Ain(Ain[11:8]), .Bin(Bin[11:8]), .Cin(Cout2), .Zout(Zout[11:8]), .Cout(Cout3));
	op_add_4 OP4(.Ain(Ain[15:12]), .Bin(Bin[15:12]), .Cin(Cout3), .Zout(Zout[15:12]), .Cout(Cout));
endmodule

// this is a carry-look-ahead algorithm
module op_add_4(input [3:0] Ain, Bin, input wire Cin, output [3:0] Zout, output wire Cout);
	wire [3:0] P, G, c;
	
	assign P = Ain ^ Bin;
	assign G = Ain & Bin;
	
	assign c[0] = Cin; // G0 + P0C0
	assign c[1] = G[0] | (P[0] & c[0]); // G1 + P1C1 = G1 + P1G0 + P1P0G0
	assign c[2] = G[1] | (P[1] & G[0]) | (P[1] & P[0] & c[0]);
	assign c[3] = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) | (P[2] & P[1] & P[0] & c[0]);
	
	assign Cout = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]) | (P[3] & P[2] & P[1] & P[0] & c[0]);
	assign Zout = P ^ c;
endmodule

// Someone asked me about this so I showed a more minimal of op_add_4
// Typically a full-adder is 2 xor's, 2 and's and 1 or
// op_add_4 is just op_add_1 done 4 times with everything all combined
module op_add_1(input Ain, Bin, input wire Cin, output Zout, output wire Cout);
	wire P, G;
	assign P = Ain ^ Bin;
	assign G = Ain & Bin;
	assign Cout = G | (P & Cin);
	assign Zout = P ^ Cin;
endmodule