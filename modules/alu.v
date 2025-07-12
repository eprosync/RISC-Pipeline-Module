// ALU - Arithmetic Logic Unit
// Responsible for operations with arithmetic

module ALU_32(
        input Clock, Clear, Branch, IncrementPC, // System Control Lines
        input [4:0] Control, // Which operator to use? (decoded from ID stage)
        input [31:0] reg_A, reg_B, // Input
        output reg [63:0] reg_C // Output
    );

    parameter
        // MEMORY
        load_select = 5'b0,
        load_imm_select = 5'b1,
        store_select = 5'b10,

        // REG-OPS
        add_select = 5'b11,
        sub_select = 5'b100,
        and_select = 5'b101,
        or_select = 5'b110,

        shr_select = 5'b111,
        shra_select = 5'b1000,
        shl_select = 5'b1001,

        ror_select = 5'b1010,
        rol_select = 5'b1011,

        // IMM-OPS
        addi_select = 5'b1100,
        andi_select = 5'b1101,
        ori_select = 5'b1110,

        mul_select = 5'b1111,
        div_select = 5'b10000,

        neg_select = 5'b10001,
        not_select = 5'b10010,

        // CONDITIONALS (branching)
        br_select = 5'b10011,
        
        // This is known as CALL and RET
        // jr - jump return, jal - jump call
        jr_select = 5'b10100,
        jal_select = 5'b10101,

        // IO PORT REGISTERS
        in_select = 5'b10110,
        out_select = 5'b10111,

        // HI-LO REGISTERS
        mfhi_select = 5'b11000,
        mflo_select = 5'b11001,
        
        // MISC
        nop_select = 5'b11010,
        halt_select = 5'b11011;

    // It may sound bad having these all connected with no switches
    // But this is fine, technically all ALU's do this, they just match at the output for what you want as a result
    wire [31:0] add_out, sub_out;
    wire add_cout_void;
    op_add_32 add_op (.Ain(reg_A),.Bin(reg_B),.Cin(1'b0),.Zout(add_out),.Cout(add_cout_void));
    op_sub_32 sub_op (.Ain(reg_A),.Bin(reg_B),.Zout(sub_out));
	 
	wire [63:0] mul_out, div_out;
    op_mul_32 mul_op (.Ain(reg_A),.Bin(reg_B),.Zout(mul_out));
    op_div_32 div_op (.Ain(reg_A),.Bin(reg_B),.Zout(div_out));

	wire [31:0] shl_out, shr_out, shra_out;
    op_shl_32 shl_op (.Ain(reg_A),.Bin(reg_B),.Zout(shl_out));
    op_shr_32 shr_op (.Ain(reg_A),.Bin(reg_B),.Zout(shr_out));
    op_shra_32 shra_op (.Ain(reg_A),.Bin(reg_B),.Zout(shra_out));

	wire [31:0] rol_out, ror_out;
    op_rol_32 rol_op (.Ain(reg_A),.Bin(reg_B),.Zout(rol_out));
    op_ror_32 ror_op (.Ain(reg_A),.Bin(reg_B),.Zout(ror_out));

    // Should probably add more operators here, like XOR, prob some N versions of them as well
	wire [31:0] and_out, or_out;
    op_and_32 and_op (.Ain(reg_A),.Bin(reg_B),.Zout(and_out));
    op_or_32 or_op (.Ain(reg_A),.Bin(reg_B),.Zout(or_out));
    
	wire [31:0] not_out, neg_out;
    op_not_32 not_op (.Ain(reg_B),.Zout(not_out));
    op_neg_32 neg_op (.Ain(reg_B),.Zout(neg_out));

    // Was using this for debugging just to release reg_C when dealing with Clock dependancy
    /*always @ (posedge Clock)
    begin
        reg_C = 32'b0;
    end*/

    always @ (negedge Clock) // ALU can always be running, shouldn't break, as we are just looking at the output from CU
    begin
        // Normally this would go through the ADD operator, but I just got lazy I guess...
        if (IncrementPC) begin
            reg_C[31:0] = reg_B + 1;
            reg_C[63:32] = 32'b0;
            $display("%0t [ALU] PC +1", $time);
        end else begin
            $display("%0t [ALU] OP %b", $time, Control);
            case(Control)
                add_select, addi_select: begin
                    reg_C[31:0] = add_out;
                    reg_C[63:32] = 32'b0;
                    $display("%0t [ALU] ADD A = %h, B = %h, C = %h", $time, reg_A, reg_B, reg_C);
                end
                sub_select: begin
                    reg_C[31:0] = sub_out;
                    reg_C[63:32] = 32'b0;
                    $display("%0t [ALU] SUB A = %h, B = %h, C = %h", $time, reg_A, reg_B, reg_C);
                end

                mul_select: begin
                    reg_C = mul_out;
                    $display("%0t [ALU] MUL A = %h, B = %h, C = %h", $time, reg_A, reg_B, reg_C);
                end
                div_select: begin
                    reg_C = div_out;
                    $display("%0t [ALU] DIV A = %h, B = %h, C = %h", $time, reg_A, reg_B, reg_C);
                end

                shl_select: begin
                    reg_C[31:0] = shl_out;
                    reg_C[63:32] = 32'b0;
                    $display("%0t [ALU] SHL A = %h, B = %h, C = %h", $time, reg_A, reg_B, reg_C);
                end
                shr_select: begin
                    reg_C[31:0] = shr_out;
                    reg_C[63:32] = 32'b0;
                    $display("%0t [ALU] SHR A = %h, B = %h, C = %h", $time, reg_A, reg_B, reg_C);
                end
                shra_select: begin
                    reg_C[31:0] = shra_out;
                    reg_C[63:32] = 32'b0;
                    $display("%0t [ALU] SHRA A = %h, B = %h, C = %h", $time, reg_A, reg_B, reg_C);
                end
                rol_select: begin
                    reg_C[31:0] = rol_out;
                    reg_C[63:32] = 32'b0;
                    $display("%0t [ALU] ROL A = %h, B = %h, C = %h", $time, reg_A, reg_B, reg_C);
                end
                ror_select: begin
                    reg_C[31:0] = ror_out;
                    reg_C[63:32] = 32'b0;
                    $display("%0t [ALU] ROR A = %h, B = %h, C = %h", $time, reg_A, reg_B, reg_C);
                end

                and_select, andi_select: begin
                    reg_C[31:0] = and_out;
                    reg_C[63:32] = 32'b0;
                    $display("%0t [ALU] AND A = %h, B = %h, C = %h", $time, reg_A, reg_B, reg_C);
                end
                or_select, ori_select: begin
                    reg_C[31:0] = or_out;
                    reg_C[63:32] = 32'b0;
                    $display("%0t [ALU] OR A = %h, B = %h, C = %h", $time, reg_A, reg_B, reg_C);
                end
                not_select: begin
                    reg_C[31:0] = not_out;
                    reg_C[63:32] = 32'b0;
                    $display("%0t [ALU] NOT %h, C = %h", $time, reg_B, reg_C);
                end
                neg_select: begin
                    reg_C[31:0] = neg_out;
                    reg_C[63:32] = 32'b0;
                    $display("%0t [ALU] NEG %h, C = %h", $time, reg_B, reg_C);
                end

                br_select: begin
                    if (Branch) begin
                        reg_C[31:0] = add_out;
                        reg_C[63:32] = 32'b0;
                        $display("%0t [ALU] BR A = %h, B = %h", $time, reg_A, reg_B);
                    end else begin
                        reg_C[31:0] = reg_A; // if we aren't branching just pass PC through
                        reg_C[63:32] = 32'b0;
                        $display("%0t [ALU] BR (failed) PC unchanged A = %h, B = %h", $time, reg_A, reg_B);
                    end
                end

                load_select, load_imm_select, store_select: begin
                    reg_C[31:0] = add_out;
                    reg_C[63:32] = 32'b0;
                    $display("%0t [ALU] LD/ST A = %h, B = %h, C = %h", $time, reg_A, reg_B, reg_C);
                end

                halt_select, nop_select: begin
                    $display("%0t [ALU] HALT/NOP", $time);
                end

                default: begin
                    reg_C[63:0] = 64'b0;
                    $display("%0t [ALU] Error: Unknown operation!", $time);
                end
            endcase
        end
    end
endmodule