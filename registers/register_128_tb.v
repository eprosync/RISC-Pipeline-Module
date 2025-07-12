module register_128_tb;

	// Declare inputs and outputs
	reg [127:0] D;
	reg Clear, Clock, Write;
	wire [127:0] Q;

	// Instantiate module under test
	register_128 dut(
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
		D = 128'b0;
			
		Clock = 1; #10;
		Clock = 0; #10;

		D = 128'h0006_0000_0003;
		Write = 1;
			
		Clock = 1; #10;
		Clock = 0; #10;

		D = 128'h0000_0006;
		Write = 1;
			
		Clock = 1; #10;
		Clock = 0; #10;

		Clear = 1;

		Clock = 1; #10;
	end
endmodule
