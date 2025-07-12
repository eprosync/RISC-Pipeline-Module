// This is the datapath, which is a culmination of all modules combined
// In a sense this is where we wire everything up

module datapath(
        input Clock, Reset, Stop, Clear,
        output Run,
        output wire [31:0] OUTPORT_data_out,
        input wire [31:0] INPORT_data_in,

        // Program Counter & Instruction
        input wire PCin, PCout, IncrementPC, IRin,
        output wire [31:0] PC_data_out,

        // Enablers
        output wire [4:0] busmux_selector,
        input wire Gra, Grb, Grc, Rin, Rout, BAout,
        input wire HIin, LOin,

        // Outputers
        input wire HIout, LOout, OUTPORTin, INPORTout, Cout,
        output wire [31:0] HI_data_out, LO_data_out, INPORT_data_out, C_data_out,

        // ALU
        input wire Yin, Zin, ZHIout, ZLOout,
        output wire [31:0] Y_data_out,
        output wire [63:0] Z_data_out,
        input wire CON_FF_in,
        output wire Branch,

        // Memory Management
        input wire MDRin, MARin, MDRout, Read, Write,
        input wire [31:0] Mdatain, Mdataout,
        output wire [31:0] MDR_data_in, MDR_data_out, MAR_data_out,
        output wire [31:0] ROM_data_out,

        // Debug
        output wire [31:0] R0_data_out, R1_data_out, R2_data_out, R3_data_out, R4_data_out, R5_data_out, R6_data_out, R7_data_out, R8_data_out, R9_data_out, R10_data_out, R11_data_out, R12_data_out, R13_data_out, R14_data_out, R15_data_out,
        output wire [31:0] ZHI_data_out, ZLO_data_out, IR_data_out, DBus,
        output wire [15:0] Rout_cs,
        input wire [15:0] Rin_cs,
        output wire [7:0] Present_State,
        output wire R15in
    );

    // Control Unit
    CU CU(
        .Clock(Clock), .Reset(Reset), .Stop(Stop), .Clear(Clear), .Run(Run),
        .Present_State(Present_State),
        
        .PCout(PCout), .PCin(PCin), .IncrementPC(IncrementPC),
        .IRin(IRin), .IRout(IRout), .IR(IR_data_out),

        .Gra(Gra), .Grb(Grb), .Grc(Grc),
        .BAout(BAout), .Rin(Rin), .Rout(Rout),
        .Cout(Cout),

        .R15in(R15in),

        .Yin(Yin), .Zin(Zin), .ZHIout(ZHIout), .ZLOout(ZLOout),
        .CON_FF(CON_FF_in),
        .Branch(Branch),

        .MARin(MARin), .MDRin(MDRin),
        .MDRout(MDRout),
        .Read(Read), .Write(Write),

        .HIin(HIin), .LOin(LOin), .HIout(HIout), .LOout(LOout),
        .OUTPORTin(OUTPORTin), .INPORTout(INPORTout), .INPORTin(INPORTin)
    );

    // Registers
    register_32 PC(DBus, Clock, Clear, PCin, PC_data_out);
    register_32 IR(ROM_data_out, Clock, Clear, IRin, IR_data_out);
    selector_encoder selector_encoder(Gra, Grb, Grc, Rin, Rout, BAout, IR_data_out, C_data_out, Rin_cs, Rout_cs, R15in);

    register_R0_32 R0(DBus, Clock, Clear, Rin_cs[0], BAout, R0_data_out);
    register_32 R1(DBus, Clock, Clear, Rin_cs[1], R1_data_out);
    register_32 R2(DBus, Clock, Clear, Rin_cs[2], R2_data_out);
    register_32 R3(DBus, Clock, Clear, Rin_cs[3], R3_data_out);
    register_32 R4(DBus, Clock, Clear, Rin_cs[4], R4_data_out);
    register_32 R5(DBus, Clock, Clear, Rin_cs[5], R5_data_out);
    register_32 R6(DBus, Clock, Clear, Rin_cs[6], R6_data_out);
    register_32 R7(DBus, Clock, Clear, Rin_cs[7], R7_data_out);
    register_32 R8(DBus, Clock, Clear, Rin_cs[8], R8_data_out);
    register_32 R9(DBus, Clock, Clear, Rin_cs[9], R9_data_out);
    register_32 R10(DBus, Clock, Clear, Rin_cs[10], R10_data_out);
    register_32 R11(DBus, Clock, Clear, Rin_cs[11], R11_data_out);
    register_32 R12(DBus, Clock, Clear, Rin_cs[12], R12_data_out);
    register_32 R13(DBus, Clock, Clear, Rin_cs[13], R13_data_out);
    register_32 R14(DBus, Clock, Clear, Rin_cs[14], R14_data_out);
    register_32 R15(DBus, Clock, Clear, Rin_cs[15], R15_data_out);

    // Special Register
    register_32 HI(DBus, Clock, Clear, HIin, HI_data_out);
    register_32 LO(DBus, Clock, Clear, LOin, LO_data_out);
    register_32 INPORT(INPORT_data_in, Clock, Clear, 1'b1, INPORT_data_out);
    register_32 OUTPORT(DBus, Clock, Clear, OUTPORTin, OUTPORT_data_out);

    // ALU & Logic Section
    cff_logic_32 CONFF(DBus, IR_data_out[22:19], CON_FF_in, Branch);
    register_32 ZHI(Z_data_out[63:32], Clock, Clear, Zin, ZHI_data_out);
    register_32 ZLO(Z_data_out[31:0], Clock, Clear, Zin, ZLO_data_out);
    register_32 Y(DBus, Clock, Clear, Yin, Y_data_out);
    ALU_32 ALU(
        .Clock(Clock),
        .Clear(Clear),
        .Branch(Branch), 
        .IncrementPC(IncrementPC), // this just acts as a pass through with + 1
        .Control(IR_data_out[31:27]),
        .reg_A(Y_data_out),
        .reg_B(DBus),
        .reg_C(Z_data_out)
    );

    // Memory Section
    register_32 MDR(MDR_data_in, Clock, Clear, MDRin, MDR_data_out);
    register_32 MAR(DBus, Clock, Clear, MARin, MAR_data_out);
    mdmux mdmux(DBus, Mdataout, Read, MDR_data_in);
    RAM_32 RAM(Clock, Read, Write, MAR_data_out[15:0], MDR_data_out, Mdataout);

    wire ROM_nowrite;
    wire [31:0] ROM_nowrite_data;
    ROM_32 ROM(Clock, PCout, ROM_nowrite, PC_data_out[15:0], ROM_nowrite_data, ROM_data_out);

    // DBus Direction Section
    busmux_encoder busmux_encoder(
        .R0(Rout_cs[0]),
        .R1(Rout_cs[1]),
        .R2(Rout_cs[2]),
        .R3(Rout_cs[3]),
        .R4(Rout_cs[4]),
        .R5(Rout_cs[5]),
        .R6(Rout_cs[6]),
        .R7(Rout_cs[7]),
        .R8(Rout_cs[8]),
        .R9(Rout_cs[9]),
        .R10(Rout_cs[10]),
        .R11(Rout_cs[11]),
        .R12(Rout_cs[12]),
        .R13(Rout_cs[13]),
        .R14(Rout_cs[14]),
        .R15(Rout_cs[15]),

        .HI(HIout),
        .LO(LOout),
        .ZHI(ZHIout),
        .ZLO(ZLOout),
        .PC(PCout),
        .MDR(MDRout),
        .InPort(INPORTout),
        .C(Cout),

        .Control(busmux_selector)
    );

    busmux busmux(
        .R0(R0_data_out),
        .R1(R1_data_out),
        .R2(R2_data_out),
        .R3(R3_data_out),
        .R4(R4_data_out),
        .R5(R5_data_out),
        .R6(R6_data_out),
        .R7(R7_data_out),
        .R8(R8_data_out),
        .R9(R9_data_out),
        .R10(R10_data_out),
        .R11(R11_data_out),
        .R12(R12_data_out),
        .R13(R13_data_out),
        .R14(R14_data_out),
        .R15(R15_data_out),

        .HI(HI_data_out),
        .LO(LO_data_out),
        .ZHI(ZHI_data_out),
        .ZLO(ZLO_data_out),
        .PC(PC_data_out),
        .MDR(MDR_data_out),
        .InPort(INPORT_data_out),
        .C(C_data_out),

        .Control(busmux_selector),
        .BusMuxOut(DBus)
    );
endmodule