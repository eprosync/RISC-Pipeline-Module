module register_32_tb;

	// Declare inputs and outputs
	reg [31:0] D;
	reg Clear, Clock, Write;
	wire [31:0] Q;

	// Instantiate module under test
	register_32 dut(
		.D(D),
		.Clear(Clear),
		.Clock(Clock),
		.Write(Write),
		.Q(Q)
	);

	// Initialize inputs
	initial begin
		Clock = 0;
		Write = 0;
		Clear = 0;
		D = 32'h0000_0000;
			
		Clock = 1; #10;
		Clock = 0; #10;

		D = 32'h0000_0003;
		Write = 1;
			
		Clock = 1; #10;
		Clock = 0; #10;

		D = 32'h0000_0003;
		Write = 1;
			
		Clock = 1; #10;
		Clock = 0; #10;

		Clear = 1;

		Clock = 1; #10;
	end
endmodule
