// Floating points are a lot more complicted to deal with.
// This is mostly because of how we have to accomidate for such large or small numbers by exponent shifting.
// We solve this by having multiple stages (or an FSM) to solve a FP number.
// ^ We see this from already made processors like MIPS/RISC-V.
// This will also result in more hazards and stalls, since now we have to wait multiple cycles for an operation to complete.

// mantissa - this is the "raw" number information, the critical value
// exponent - this would be the shifting of 0's that the mantissa scope is in
// sign - just for 2's compliment

// Original work by Jonathan P Dawson
// MIT License as per: https://github.com/dawsonjon/fpu/issues/4
// Modified for Educational Purposes & Compute FPU Engine

module fp_add_32 (
        input       Clock, Reset,
        input       A_edge, B_edge, // If you want to overwrite A, B, you need the high, since this is state machine...
        input       A_ack, B_ack, // Acknowledgements that we have received your registers, you may now proceed!
        input       [31:0] A, B,
        output reg  Zout_ready, Zout_ack, // When this when we are done calculating
        output reg  [31:0] Zout
    );

    // Temporary Registers
    // Used during the state machine's runtime
    reg [31:0] a, b, z;
    reg sign_a; reg [7:0] exp_a; reg [22:0] mant_a;
    reg sign_b; reg [7:0] exp_b; reg [22:0] mant_b;
    reg sign_z; reg [7:0] exp_z; reg [22:0] mant_z;
    reg [22:0] mant_sum; reg guard, round_bit, sticky;

    reg [3:0] state;
    parameter
        fetch         = 4'd0, // Fetch from registers A & B
        unpack        = 4'd1, // Unpack into sign, exponent & mantissa
        edgecase      = 4'd2, // Simple checks for instant calculations or prevent undesired behavior
        align         = 4'd3, // Align makes sure the exponents are the same before performing (this can take multiple cycles)
        perform       = 4'd4, // Performs addition on mantissa (both exponents should be the same!)

        normalize     = 4'd5, // Shifts the mantissa left or right and adjusts the exponent (this can take multiple cycles)
        normalize_1   = 4'd6,
        // ^ This ensures the result is normalized into the form "1.xxx * 2^exp"
        // ^ For example, if there's a carry out (leading 1), shift right and increment exponent;
        // ^ or if too small, shift left and decrement exponent.

        round         = 4'd7, // Looks at the GRS (guard, round and sticky) and decides if we need to increment mantissa
        // ^ TL:DR if we are barely crossing the rounding threshold, round up!
        // GRS: G - 1st extra bit beyond a 23 mantissa bit (like a carry), round - 2nd extra bit, sticky - OR of all remaining bits

        pack          = 4'd8, // Packs up results into floating point register Z
        export        = 4'd9; // Let's the device know we have a result
    // This can use about ~9 cycles on an average calculation

    // This is the actual state machine here
    always @ (posedge Clock)
    begin
        case (state)
            // TODO (later): fetch, unpack, edgecase, align can be combined
            fetch: begin
                A_ack <= 1;
                B_ack <= 1;
                if (A_edge && B_edge) begin
                    a <= A; b <= B;
                    A_ack <= 0; B_ack <= 0;
                    state <= unpack;
                end
            end

            unpack: begin
                sign_a <= a[31];
                exp_a <= a[30:23];
                mant_a <= a[22:0];

                sign_b <= b[31];
                exp_b <= b[30:23];
                mant_b <= b[22:0];

                state <= edgecase;
            end

            edgecase: begin
                if ((exp_a == 128 && mant_a != 0) || (exp_b == 128 && mant_b != 0)) begin // if a is NaN or b is NaN return NaN
                    z[31] <= 1;
                    z[30:23] <= 255;
                    z[22] <= 1;
                    z[21:0] <= 0;
                    state <= put_z;
                end else if (exp_a == 128) begin // if a is inf return inf
                    z[31] <= sign_a;
                    z[30:23] <= 255;
                    z[22:0] <= 0;
                    if ((exp_b == 128) && (sign_a != sign_b)) begin // if a is inf and signs don't match return nan
                        z[31] <= sign_b;
                        z[30:23] <= 255;
                        z[22] <= 1;
                        z[21:0] <= 0;
                    end
                    state <= put_z;
                end else if (exp_b == 128) begin // if b is inf return inf
                    z[31] <= sign_b;
                    z[30:23] <= 255;
                    z[22:0] <= 0;
                    state <= put_z;
                end else if ((($signed(exp_a) == -127) && (mant_a == 0)) && (($signed(exp_b) == -127) && (mant_b == 0))) begin // if a is zero return b
                    z[31] <= sign_a & sign_b;
                    z[30:23] <= exp_b[7:0] + 127;
                    z[22:0] <= mant_b[26:3];
                    state <= put_z;
                end else if (($signed(exp_a) == -127) && (mant_a == 0)) begin // if a is zero return b
                    z[31] <= sign_b;
                    z[30:23] <= exp_b[7:0] + 127;
                    z[22:0] <= mant_b[26:3];
                    state <= put_z;
                end else if (($signed(exp_b) == -127) && (mant_b == 0)) begin // if b is zero return a
                    z[31] <= sign_a;
                    z[30:23] <= exp_a[7:0] + 127;
                    z[22:0] <= mant_a[26:3];
                    state <= put_z;
                end else begin // Denormalise
                    if ($signed(exp_a) == -127) begin
                        exp_a <= -126;
                    end else begin
                        mant_a[26] <= 1;
                    end

                    if ($signed(exp_b) == -127) begin
                        exp_b <= -126;
                    end else begin
                        mant_b[26] <= 1;
                    end

                    state <= align;
                end
            end

            align: begin
                if ($signed(exp_a) > $signed(exp_b)) begin
                    exp_b <= exp_b + 1;
                    mant_b <= mant_b >> 1;
                    mant_b[0] <= mant_b[0] | mant_b[1];
                end else if ($signed(exp_a) < $signed(exp_b)) begin
                    exp_a <= exp_a + 1;
                    mant_a <= mant_a >> 1;
                    mant_a[0] <= mant_a[0] | mant_a[1];
                end else begin
                    state <= perform;
                end
            end

            perform: begin
                exp_z <= exp_a;

                if (sign_a == sign_b) begin
                    mant_sum <= mant_a + mant_b;
                    sign_z <= sign_a;
                end else begin
                    if (mant_a >= mant_b) begin
                        mant_sum <= mant_a - mant_b;
                        sign_z <= sign_a;
                    end else begin
                        mant_sum <= mant_b - mant_a;
                        sign_z <= sign_b;
                    end
                end

                if (mant_sum[27]) begin
                    mant_z <= mant_sum[27:4];
                    guard <= mant_sum[3];
                    round_bit <= mant_sum[2];
                    sticky <= mant_sum[1] | mant_sum[0];
                    exp_z <= exp_z + 1;
                end else begin
                    mant_z <= mant_sum[26:3];
                    guard <= mant_sum[2];
                    round_bit <= mant_sum[1];
                    sticky <= mant_sum[0];
                end

                state <= normalize;
            end

            // TODO (later): normalize and normalize_1 can be combined...?
            normalize: begin
                if (mant_z[23] == 0 && $signed(exp_z) > -126) begin
                    exp_z <= exp_z - 1;
                    mant_z <= mant_z << 1;
                    mant_z[0] <= guard;
                    guard <= round_bit;
                    round_bit <= 0;
                end else begin
                    state <= normalize_1;
                end
            end

            normalize_1: begin
                if ($signed(exp_z) < -126) begin
                    exp_z <= exp_z + 1;
                    mant_z <= mant_z >> 1;
                    guard <= mant_z[0];
                    round_bit <= guard;
                    sticky <= sticky | round_bit;
                end else begin
                    state <= round;
                end
            end

            round: begin
                if (guard && (round_bit | sticky | mant_z[0])) begin
                    mant_z <= mant_z + 1;
                    if (mant_z == 24'hffffff) begin
                        exp_z <=exp_z + 1;
                    end
                end
                state <= pack;
            end

            pack: begin
                z[22 : 0] <= mant_z[22:0];
                z[30 : 23] <= exp_z[7:0] + 127;
                z[31] <= sign_z;

                if ($signed(exp_z) == -126 && mant_z[23] == 0) begin
                    z[30 : 23] <= 0;
                end

                if ($signed(exp_z) == -126 && mant_z[23:0] == 24'h0) begin
                    z[31] <= 1'b0; // FIX SIGN BUG: -a + a = +0.
                end
                
                if ($signed(exp_z) > 127) begin // if overflow occurs, return inf
                    z[22 : 0] <= 0;
                    z[30 : 23] <= 255;
                    z[31] <= sign_z;
                end

                state <= put_z;
            end

            export: begin
                Zout_ready <= 1;
                Zout <= z;
                if (Zout_ack) begin
                    Zout_ready <= 0;
                    state <= fetch;
                end
            end
        endcase

        if (Reset == 1) begin
            state <= fetch;
            A_ack <= 0; B_ack <= 0; Zout_ready <= 0;
        end
    end
endmodule