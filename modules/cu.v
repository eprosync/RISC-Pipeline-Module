// CU - Control Unit
// This is responsible for actually creating a runtime for instructions
// Providing for things like states n such, just think of it as a giant state-machine of logical inputs

`timescale 1ns / 1ps

module CU(
        // Control Unit Specific
        input Clock, Reset, Stop, Clear,
        output reg Run,
        
        // Register selector
        output reg Gra, Grb, Grc,
        output reg BAout, Rin, Rout,
        output reg Cout, // for the C_sign_extended for immediates

        // Program information
        output reg PCout, PCin, IncrementPC,
        output reg IRout, IRin,
        inout [31:0] IR,
        output reg CON_FF,
        input Branch,

        // This is for Jump Call
        output reg R15in,

        // ALU
        output reg Yin, Zin, ZHIout, ZLOout,

        // Memory
        output reg MARin, MDRin,
        output reg MDRout,
        output reg Read, Write,

        // Specialized Registers
        output reg HIin, LOin, HIout, LOout,
        output reg OUTPORTin, INPORTout, INPORTin,

        // Debug
        output reg [7:0] Present_State
    );

    parameter
        state_reset = 8'b0,

        inst_fetch_PC = 8'b1,
        inst_fetch_READ = 8'b10,
        inst_fetch_IR = 8'b11,

        op_ld_T0 = 8'b100,
        op_ld_T1 = 8'b101,
        op_ld_T2 = 8'b110,
        op_ld_T3 = 8'b111,
        op_ld_T4 = 8'b1000,

        op_ldi_T0 = 8'b1001,
        op_ldi_T1 = 8'b1010,
        op_ldi_T2 = 8'b1011,

        op_st_T0 = 8'b1100,
        op_st_T1 = 8'b1101,
        op_st_T2 = 8'b1110,
        op_st_T3 = 8'b1111,
        op_st_T4 = 8'b10000,

        op_add_T0 = 8'b10001,
        op_add_T1 = 8'b10010,
        op_add_T2 = 8'b10011,

        op_sub_T0 = 8'b10101,
        op_sub_T1 = 8'b10110,
        op_sub_T2 = 8'b10111,

        op_and_T0 = 8'b11000,
        op_and_T1 = 8'b11001,
        op_and_T2 = 8'b11010,

        op_or_T0 = 8'b11011,
        op_or_T1 = 8'b11100,
        op_or_T2 = 8'b11101,

        op_shr_T0 = 8'b11110,
        op_shr_T1 = 8'b11111,
        op_shr_T2 = 8'b100000,

        op_shra_T0 = 8'b100001,
        op_shra_T1 = 8'b100010,
        op_shra_T2 = 8'b100011,

        op_shl_T0 = 8'b100100,
        op_shl_T1 = 8'b100101,
        op_shl_T2 = 8'b100110,

        op_ror_T0 = 8'b100111,
        op_ror_T1 = 8'b101000,
        op_ror_T2 = 8'b101001,

        op_rol_T0 = 8'b101010,
        op_rol_T1 = 8'b101011,
        op_rol_T2 = 8'b101100,

        op_addi_T0 = 8'b101101,
        op_addi_T1 = 8'b101110,
        op_addi_T2 = 8'b101111,

        op_andi_T0 = 8'b110000,
        op_andi_T1 = 8'b110001,
        op_andi_T2 = 8'b110010,

        op_ori_T0 = 8'b110011,
        op_ori_T1 = 8'b110100,
        op_ori_T2 = 8'b110101,

        op_mul_T0 = 8'b110110,
        op_mul_T1 = 8'b110111,
        op_mul_T2 = 8'b111000,
        op_mul_T3 = 8'b111001,

        op_div_T0 = 8'b111010,
        op_div_T1 = 8'b111011,
        op_div_T2 = 8'b111100,
        op_div_T3 = 8'b111101,

        op_neg_T0 = 8'b111110,
        op_neg_T1 = 8'b111111,

        op_not_T0 = 8'b1000000,
        op_not_T1 = 8'b1000001,

        op_br_T0 = 8'b1000010,
        op_br_T1 = 8'b1000011,
        op_br_T2 = 8'b1000100,
        op_br_T3 = 8'b1000101,

        op_jr_T0 = 8'b1000110,

        op_jal_T0 = 8'b1000111,
        op_jal_T1 = 8'b1001000,

        op_in_T0 = 8'b1001001,
        op_out_T0 = 8'b1001010,
        op_mfhi_T0 = 8'b1001011,
        op_mflo_T0 = 8'b1001100,

        op_halt_T0 = 8'b1001101,
        op_nop_T0 = 8'b1001110;

    initial begin
        Present_State = state_reset;
    end

        // state machine
    always @ (posedge Clock, posedge Reset, posedge Stop) 
    begin
        if (Reset) begin
            Present_State = inst_fetch_PC;
        end
        if (Stop) begin
            Present_State = op_halt_T0;
        end
        case (Present_State)
            state_reset : Present_State = inst_fetch_PC;

            inst_fetch_PC : Present_State = inst_fetch_READ;
            inst_fetch_READ : Present_State = inst_fetch_IR;
            inst_fetch_IR : begin
                // after fetching IR we need to decide what operation we will do
                $display("%0t [Control Unit] Choosing by %b", $time, IR[31:27]);
                case (IR[31:27])
                    5'b0 : Present_State = op_ld_T0;
                    5'b1 : Present_State = op_ldi_T0;
                    5'b10 : Present_State = op_st_T0;
                    5'b11 : Present_State = op_add_T0;
                    5'b100 : Present_State = op_sub_T0;
                    5'b101 : Present_State = op_and_T0;
                    5'b110 : Present_State = op_or_T0;
                    5'b111 : Present_State = op_shr_T0;
                    5'b1000 : Present_State = op_shra_T0;
                    5'b1001 : Present_State = op_shl_T0;
                    5'b1010 : Present_State = op_ror_T0;
                    5'b1011 : Present_State = op_rol_T0;
                    5'b1100 : Present_State = op_addi_T0;
                    5'b1101 : Present_State = op_andi_T0;
                    5'b1110 : Present_State = op_ori_T0;
                    5'b1111 : Present_State = op_mul_T0;
                    5'b10000 : Present_State = op_div_T0;
                    5'b10001 : Present_State = op_neg_T0;
                    5'b10010 : Present_State = op_not_T0;
                    5'b10011 : Present_State = op_br_T0;
                    5'b10100 : Present_State = op_jr_T0;
                    5'b10101 : Present_State = op_jal_T0;
                    5'b10110 : Present_State = op_in_T0;
                    5'b10111 : Present_State = op_out_T0;
                    5'b11000 : Present_State = op_mfhi_T0;
                    5'b11001 : Present_State = op_mflo_T0;
                    5'b11010 : Present_State = op_nop_T0;
                    5'b11011 : Present_State = op_halt_T0;
                    default : begin
                        Present_State = op_halt_T0;
                        #1 $display("%0t [Control Unit] Error: Operation not found! -> %b\nHalting procedure!", $time, IR[31:27]);
                    end
                endcase
            end

            op_ld_T0 : Present_State = op_ld_T1;
            op_ld_T1 : Present_State = op_ld_T2;
            op_ld_T2 : Present_State = op_ld_T3;
            op_ld_T3 : Present_State = op_ld_T4;
            op_ld_T4 : Present_State = inst_fetch_PC;
        
            op_ldi_T0 : Present_State = op_ldi_T1;
            op_ldi_T1 : Present_State = op_ldi_T2;
            op_ldi_T2 : Present_State = inst_fetch_PC;
        
            op_st_T0 : Present_State = op_st_T1;
            op_st_T1 : Present_State = op_st_T2;
            op_st_T2 : Present_State = op_st_T3;
            op_st_T3 : Present_State = op_st_T4;
            op_st_T4 : Present_State = inst_fetch_PC;
        
            op_add_T0 : Present_State = op_add_T1;
            op_add_T1 : Present_State = op_add_T2;
            op_add_T2 : Present_State = inst_fetch_PC;
        
            op_sub_T0 : Present_State = op_sub_T1;
            op_sub_T1 : Present_State = op_sub_T2;
            op_sub_T2 : Present_State = inst_fetch_PC;
        
            op_and_T0 : Present_State = op_and_T1;
            op_and_T1 : Present_State = op_and_T2;
            op_and_T2 : Present_State = inst_fetch_PC;
        
            op_or_T0 : Present_State = op_or_T1;
            op_or_T1 : Present_State = op_or_T2;
            op_or_T2 : Present_State = inst_fetch_PC;
        
            op_shr_T0 : Present_State = op_shr_T1;
            op_shr_T1 : Present_State = op_shr_T2;
            op_shr_T2 : Present_State = inst_fetch_PC;
        
            op_shra_T0 : Present_State = op_shra_T1;
            op_shra_T1 : Present_State = op_shra_T2;
            op_shra_T2 : Present_State = inst_fetch_PC;
        
            op_shl_T0 : Present_State = op_shl_T1;
            op_shl_T1 : Present_State = op_shl_T2;
            op_shl_T2 : Present_State = inst_fetch_PC;
        
            op_ror_T0 : Present_State = op_ror_T1;
            op_ror_T1 : Present_State = op_ror_T2;
            op_ror_T2 : Present_State = inst_fetch_PC;
        
            op_rol_T0 : Present_State = op_rol_T1;
            op_rol_T1 : Present_State = op_rol_T2;
            op_rol_T2 : Present_State = inst_fetch_PC;
        
            op_addi_T0 : Present_State = op_addi_T1;
            op_addi_T1 : Present_State = op_addi_T2;
            op_addi_T2 : Present_State = inst_fetch_PC;
        
            op_andi_T0 : Present_State = op_andi_T1;
            op_andi_T1 : Present_State = op_andi_T2;
            op_andi_T2 : Present_State = inst_fetch_PC;
        
            op_ori_T0 : Present_State = op_ori_T1;
            op_ori_T1 : Present_State = op_ori_T2;
            op_ori_T2 : Present_State = inst_fetch_PC;
        
            op_mul_T0 : Present_State = op_mul_T1;
            op_mul_T1 : Present_State = op_mul_T2;
            op_mul_T2 : Present_State = op_mul_T3;
            op_mul_T3 : Present_State = inst_fetch_PC;
        
            op_div_T0 : Present_State = op_div_T1;
            op_div_T1 : Present_State = op_div_T2;
            op_div_T2 : Present_State = op_div_T3;
            op_div_T3 : Present_State = inst_fetch_PC;
        
            op_neg_T0 : Present_State = op_neg_T1;
            op_neg_T1 : Present_State = inst_fetch_PC;
        
            op_not_T0 : Present_State = op_not_T1;
            op_not_T1 : Present_State = inst_fetch_PC;
        
            op_br_T0 : Present_State = op_br_T1;
            op_br_T1 : Present_State = op_br_T2;
            op_br_T2 : Present_State = op_br_T3;
            op_br_T3 : Present_State = inst_fetch_PC;

            op_jr_T0 : Present_State = inst_fetch_PC;

            op_jal_T0 : Present_State = op_jal_T1;
            op_jal_T1 : Present_State = inst_fetch_PC;

            op_in_T0 : Present_State = inst_fetch_PC;
            op_out_T0 : Present_State = inst_fetch_PC;
            op_mflo_T0 : Present_State = inst_fetch_PC;
            op_mfhi_T0 : Present_State = inst_fetch_PC;

            // op_halt_T0 : Present_State = inst_fetch_PC;
            op_nop_T0 : Present_State = inst_fetch_PC;
        endcase
    end

    // logic machine, handles logic when state changes
    always @ (Present_State)
    begin
        case (Present_State)
            state_reset : begin
                Run <= 1; // we are now running!

                // Register selector
                Gra <= 0; Grb <= 0; Grc <= 0;
                BAout <= 0; Rin <= 0; Rout <= 0;
                Cout <= 0; // for the C_sign_extended for immediates

                // Program information
                PCout <= 0; IRout <= 0; PCin <= 0; IRin <= 0;
                IncrementPC <= 0;

                // For jal instruction
                R15in <= 0;

                // ALU
                Yin <= 0; Zin <= 0;
                ZHIout <= 0; ZLOout <= 0;

                // Memory
                MARin <= 0; MDRin <= 0;
                MDRout <= 0;
                Read <= 0; Write <= 0;

                // Special registers
                HIin <= 0; LOin <= 0; HIout <= 0; LOout <= 0;
                OUTPORTin <= 0; INPORTout <= 0; INPORTin <= 0;

                $display("%0t [Control Unit] Reset Cleaned!", $time);
            end

            // Startup of instructions
            inst_fetch_PC: begin
                // Register selector
                Gra <= 0; Grb <= 0; Grc <= 0;
                BAout <= 0; Rin <= 0; Rout <= 0;
                Cout <= 0; // for the C_sign_extended for immediates

                // Program information
                PCout <= 0; IRout <= 0; PCin <= 0; IRin <= 0;
                IncrementPC <= 0;

                // For jal instruction
                R15in <= 0;

                // ALU
                Yin <= 0; Zin <= 0;
                ZHIout <= 0; ZLOout <= 0;
                // Control <= 5'b0; // responsible for which ALU instruction

                // Memory
                MARin <= 0; MDRin <= 0;
                MDRout <= 0;
                Read <= 0; Write <= 0;

                // Special registers
                HIin <= 0; LOin <= 0; HIout <= 0; LOout <= 0;
                OUTPORTin <= 0; INPORTout <= 0; INPORTin <= 0;
                IncrementPC <= 1;
                PCout <= 1; MARin <= 1; Zin <= 1;
                // ^ tell ALU to add +1 to PC

                $display("%0t [Control Unit] Start Cleaned!", $time);
            end

            inst_fetch_READ: begin
                ZLOout <= 1; PCin <= 1;
                PCout <= 0; MARin <= 0; IncrementPC <= 0; Zin <= 0;
                Read <= 1; MDRin <= 1;
                // return from ALU the PC + 1 and write it to the PC register
                // at the same time the original PC from isnt_fetch_PC should be in MAR to read from RAM the instructions
            end

            inst_fetch_IR: begin
                ZLOout <= 0; PCin <= 0; MDRin <= 0; Read <= 0;
                MDRout <= 1; IRin <= 1;
            end

            // load
            op_ld_T0: begin
                MDRout <= 0; IRin <= 0;
                Grb <= 1; BAout <= 1; Yin <= 1;
                $display("%0t [Control Unit] Instruction ld", $time);
            end

            op_ld_T1: begin
                Grb <= 0; BAout <= 0; Yin <= 0;
                Cout <= 1; Zin <= 1;
            end

            op_ld_T2: begin
                Cout <= 0; Zin <= 0;
			    ZLOout <= 1; MARin <= 1;
            end

            op_ld_T3: begin
			    ZLOout <= 0; MARin <= 0;
                MDRin <= 1; Read <= 1;
            end

            op_ld_T4: begin
                Read <= 0; MDRin <= 0;
			    MDRout <= 1; Gra <= 1; Rin <= 1;
            end

            // loadi
            op_ldi_T0: begin
                MDRout <= 0; IRin <= 0;
                Grb <= 1; BAout <= 1; Yin <= 1;
                $display("%0t [Control Unit] Instruction ldi", $time);
            end

            op_ldi_T1: begin
                Grb <= 0; BAout <= 0; Yin <= 0;
                Cout <= 1; Zin <= 1;
            end

            op_ldi_T2: begin
                Cout <= 0; Zin <= 0;
                ZLOout <= 1; Gra <= 1; Rin <= 1;
            end

            // store
            op_st_T0: begin
                MDRout <= 0; IRin <= 0;
                Grb <= 1; BAout <= 1; Yin <= 1;
                $display("%0t [Control Unit] Instruction st", $time);
            end

            op_st_T1: begin
                Grb <= 0; BAout <= 0; Yin <= 0;
                Cout <= 1; Zin <= 1;
            end

            op_st_T2: begin
                Cout <= 0; Zin <= 0;
			    ZLOout <= 1; MARin <= 1;
            end

            op_st_T3: begin
			    ZLOout <= 0; MARin <= 0;
                MDRin <= 1; Gra <= 1; Rout <= 1;
            end

            op_st_T4: begin
                MDRin <= 0; Gra <= 0; Rout <= 0;
			    Write <= 1; 
            end

            // add, sub
            op_add_T0, op_sub_T0: begin
                MDRout <= 0; IRin <= 0;
                Grb <= 1; Rout <= 1; Yin <= 1;
                $display("%0t [Control Unit] Instruction add/sub", $time);
            end

            op_add_T1, op_sub_T1: begin
                Grb <= 0; Rout <= 0; Yin <= 0;
                Grc <= 1; Rout <= 1; Zin <= 1;
            end

            op_add_T2, op_sub_T2: begin
                Grc <= 0; Rout <= 0; Zin <= 0;
                ZLOout <= 1; Gra <= 1; Rin <= 1;
            end

            // and, or, shr, shra, shl, ror, rol
            op_and_T0, op_or_T0, op_shr_T0, op_shra_T0, op_shl_T0, op_ror_T0, op_rol_T0: begin
                MDRout <= 0; IRin <= 0;
                Grb <= 1; Rout <= 1; Yin <= 1;
                $display("%0t [Control Unit] Instruction add/or/shr/shra/shl/ror/rol", $time);
            end

            op_and_T1, op_or_T1, op_shr_T1, op_shra_T1, op_shl_T1, op_ror_T1, op_rol_T1: begin
                Grb <= 0; Rout <= 0; Yin <= 0;
                Grc <= 1; Rout <= 1; Zin <= 1;
            end

            op_and_T2, op_or_T2, op_shr_T2, op_shra_T2, op_shl_T2, op_ror_T2, op_rol_T2: begin
                Grc <= 0; Rout <= 0; Zin <= 0;
                Gra <= 1; Rin <= 1; ZLOout <= 1;
            end

            // mul, div
            op_mul_T0, op_div_T0: begin
                MDRout <= 0; IRin <= 0;
                Gra <= 1; Rout <= 1; Yin <= 1;
                $display("%0t [Control Unit] Instruction mul/div", $time);
            end

            op_mul_T1, op_div_T1: begin
                Gra <= 0; Rout <= 0; Yin <= 0;
                Grb <= 1; Rout <= 1; Zin <= 1;
            end

            op_mul_T2, op_div_T2: begin
                Grb <= 0; Rout <= 0; Zin <= 0;
                LOin <= 1; ZLOout <= 1;
            end

            op_mul_T3, op_div_T3: begin
                LOin <= 0; ZLOout <= 0;
                HIin <= 1; ZHIout <= 1;
            end

            // neg, not
            op_neg_T0, op_not_T0: begin
                MDRout <= 0; IRin <= 0;
                Grb <= 1; Rout <= 1; Zin <= 1;
                $display("%0t [Control Unit] Instruction neg/not", $time);
            end

            op_neg_T1, op_not_T1: begin
                Grb <= 0; Rout <= 0; Zin <= 0;
                Gra <= 1; Rin <= 1; ZLOout <= 1;
            end

            // addi, andi, ori
            op_addi_T0, op_andi_T0, op_ori_T0: begin
                MDRout <= 0; IRin <= 0;
                Grb <= 1; Rout <= 1; Yin <= 1;
                $display("%0t [Control Unit] Instruction addi/andi/ori", $time);
            end

            op_addi_T1, op_andi_T1, op_ori_T1: begin
                Grb <= 0; Rout <= 0; Yin <= 0;
                Cout <= 1; Zin <= 1;
            end

            op_addi_T2, op_andi_T2, op_ori_T2: begin
                Cout <= 0; Zin <= 0;
                Gra <= 1; Rin <= 1; ZLOout <= 1;
            end

            // jr
            op_jr_T0: begin
                MDRout <= 0; IRin <= 0;
                Gra <= 1; Rout <= 1; PCin <= 1;
                $display("%0t [Control Unit] Instruction jr", $time);
            end

            // jal (come back to this)
            op_jal_T0: begin
                MDRout <= 0; IRin <= 0;
                PCout <= 1; R15in <= 1;
                // IR_copy <= {IR[31:23], IR[22:0] | 9'b1111_0000_0000}; // overwrite Grb to target 15'th register
                // in call instructions we typically need to target registers that are least to be touched, R0 is an exception
                $display("%0t [Control Unit] Instruction jal", $time);
            end

            op_jal_T1: begin
                R15in <= 0; PCout <= 0;
                Gra <= 1; Rout <= 1; PCin <= 1;
            end

            // mfhi
            op_mfhi_T0: begin
                MDRout <= 0; IRin <= 0;
                Gra <= 1; Rin <= 1; HIout <= 1;
                $display("%0t [Control Unit] Instruction mfhi", $time);
            end

            // mflo
            op_mflo_T0: begin
                MDRout <= 0; IRin <= 0;
                Gra <= 1; Rin <= 1; LOout <= 1;
                $display("%0t [Control Unit] Instruction mflo", $time);
            end

            // in
            op_in_T0: begin
                MDRout <= 0; IRin <= 0;
                Gra <= 1; Rin <= 1; INPORTout <= 1;
                $display("%0t [Control Unit] Instruction in", $time);
            end

            // out
            op_out_T0: begin
                MDRout <= 0; IRin <= 0;
                Gra <= 1; Rout <= 1; OUTPORTin <= 1;
                $display("%0t [Control Unit] Instruction out", $time);
            end

            // br
            op_br_T0: begin
                MDRout <= 0; IRin <= 0;
                Gra <= 1; Rout <= 1; CON_FF <= 1;
                $display("%0t [Control Unit] Instruction br", $time);
            end

            op_br_T1: begin
                Gra <= 0; Rout <= 0; CON_FF <= 0;
                PCout <= 1; Yin <= 1;
            end

            op_br_T2: begin
                PCout <= 0; Yin <= 0;
                Cout <= 1; Zin <= 1;
            end

            op_br_T3: begin
                Cout <= 0; Zin <= 0;
                ZLOout <= 1; PCin <= 1;
            end
            
            // nop & halt
            op_halt_T0 : begin
                Run <= 0;
                $display("%0t [Control Unit] Instruction halt", $time);
            end
            op_nop_T0 : begin
                $display("%0t [Control Unit] Instruction nop", $time);
            end
            default : begin end
        endcase
    end
endmodule