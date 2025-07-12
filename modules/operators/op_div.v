// This is the complicated restoring division algorithm

module op_div_64(input [63:0] Ain, Bin, output reg [127:0] Zout);
    reg signed [127:0] remainder;
    reg signed [63:0] divisor, dividend;
    reg signed [63:0] abs_dividend, abs_divisor;
    reg [63:0] quotient;

    integer i;

    always @(*) begin
        dividend = $signed(Ain);
        divisor  = $signed(Bin);
        quotient = 0;
        remainder = 0;

        // NAN / DIV-by-ZERO, since I don't want this to break
        if (Bin == 0) begin
            Zout = 128'hFFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF;
        end else begin
            // Convert to absolute values for processing
            abs_dividend = (dividend < 0) ? -dividend : dividend;
            abs_divisor  = (divisor  < 0) ? -divisor  : divisor;

            // Perform unsigned restoring division
            for (i = 63; i >= 0; i = i - 1) begin
                remainder = (remainder << 1) | ((abs_dividend >> i) & 1);
                if (remainder >= abs_divisor) begin
                    remainder = remainder - abs_divisor;
                    quotient[i] = 1;
                end else begin
                    quotient[i] = 0;
                end
            end

            if (dividend[63] ^ divisor[63]) begin
                quotient = -quotient;
            end
            if (dividend[63]) begin
                remainder = -remainder;
            end

            Zout = {remainder[63:0], quotient};
        end
    end
endmodule

module op_div_32(input [31:0] Ain, Bin, output reg [63:0] Zout);
    reg signed [63:0] remainder;
    reg signed [31:0] divisor, dividend;
    reg signed [31:0] abs_dividend, abs_divisor;
    reg [31:0] quotient;

    integer i;

    always @(*) begin
        dividend = $signed(Ain);
        divisor  = $signed(Bin);
        quotient = 0;
        remainder = 0;

        // NAN / DIV-by-ZERO
        if (Bin == 0) begin
            Zout = 64'hFFFFFFFF_FFFFFFFF;
        end else begin
            // Convert to absolute values for processing
            abs_dividend = (dividend < 0) ? -dividend : dividend;
            abs_divisor  = (divisor  < 0) ? -divisor  : divisor;

            // Perform unsigned restoring division
            for (i = 31; i >= 0; i = i - 1) begin
                remainder = (remainder << 1) | ((abs_dividend >> i) & 1);
                if (remainder >= abs_divisor) begin
                    remainder = remainder - abs_divisor;
                    quotient[i] = 1;
                end else begin
                    quotient[i] = 0;
                end
            end

            if (dividend[31] ^ divisor[31]) begin
                quotient = -quotient;
            end
            if (dividend[31]) begin
                remainder = -remainder;
            end

            Zout = {remainder[31:0], quotient};
        end
    end
endmodule

// Cheap alternative if the one I made didn't work
/*
module op_div_64(input [63:0] Ain, Bin, output reg [127:0] Zout);
	reg signed [63:0] A, B;

	always @ (*)
	begin
		A = $signed(Ain);
		B = $signed(Bin);
		Zout = (A - (A % B)) / B;
	end
endmodule

module op_div_32(input [31:0] Ain, Bin, output reg [63:0] Zout);
	reg signed [31:0] A, B;

	always @ (*)
	begin
		A = $signed(Ain);
		B = $signed(Bin);
		Zout = (A - (A % B)) / B;
	end
endmodule
*/

// Old version I attempted at restoring division
/*module op_div_32(input [31:0] Ain, Bin, output [63:0] Zout);
    reg [64:0] dividend_storage;
    reg signed [31:0] divisor_storage;
    reg signed [31:0] remainder_storage;
    reg [31:0] clamp;
    reg q;
    integer i, length;

    // Restoring division algorithm
    always @ (*) begin
        dividend_storage = $signed(Ain); // This is Q
        divisor_storage = $signed(Bin); // This is M
        remainder_storage = divisor_storage; // This is A
        q = 0;

        // Get the bit length of Q
        for (i=0; i<31; i=i+1) begin : find_bit_length
            if (Ain[i]) begin
                length = i;
            end
        end

        // Create a clamp to prevent bits from going outside the length
        for (i=0; i<length; i=i+1) begin : create_clamp
            clamp[i] = 1;
        end
        
        // Now use a for loop for it all
        for (i=0; i<length; i=i+1) begin : restore_division
            if (i == 0) begin
                remainder_storage = {remainder_storage[31:1], 1'b0};
                // This is a right shift
            end else begin
                remainder_storage = {1'b0, remainder_storage[30:0]};
                // This is a left shift
            end

            remainder_storage = remainder_storage - divisor_storage;
            
            if (remainder_storage[31]) begin
                q = 0;
                remainder_storage = remainder_storage + divisor_storage;
            end else begin
                q = 1;
            end

            dividend_storage = {remainder_storage[31:1], 1'b0};
            dividend_storage[0] = q;
        end

        dividend_storage = dividend_storage & clamp; // apply clamp
    end

    assign Zout = dividend_storage[63:0];
endmodule*/