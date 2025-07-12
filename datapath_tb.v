`timescale 1ns/1ps

module datapath_tb;
    reg Clock;
    wire [7:0] Present_State;

    // select_encoder
    wire [4:0] busmux_selector;
    wire [31:0] IR, PC, C_data_out;
    wire Branch, Gra, Grb, Grc, BAout, Rin, Rout;
    wire [15:0] Rin_cs;

    wire [31:0] MAR, MDR;
    wire [31:0] HI, LO;

    // specific to T0 -> T2
    wire PCout, MARin, IncrementPC, Zin;
    wire ZLOout, PCin, Read, MDRin;
    wire [31:0] MDin, MDout;
    wire MDRout, IRin;

    // specific to T3 -> T5
    wire Yin;
    wire Cout;

    // register values & datapath, output ports should be wires!
    wire [31:0] datapath;
    wire [63:0] Z;
    wire [31:0] Y, ZHI, ZLO, MDR_data_in;
    wire [31:0] R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15;
    wire [31:0] INPORT, OUTPORT;
    reg [31:0] INPORT_data_in;
    wire [15:0] Rout_cs;
    wire R15in;

    datapath DUT(
        .Clock(Clock),
        .Present_State(Present_State),

        // select_encoder
        .busmux_selector(busmux_selector), .Branch(Branch),
        .Gra(Gra), .Grb(Grb), .Grc(Grc), .BAout(BAout), .Rin(Rin), .Rout(Rout),
        .C_data_out(C_data_out),

        .HI_data_out(HI), .LO_data_out(LO),
        .MAR_data_out(MAR), .MDR_data_out(MDR),

        // register values & datapath
        .DBus(datapath),
        .IR_data_out(IR), .PC_data_out(PC), .MDR_data_in(MDR_data_in), .Z_data_out(Z), .Y_data_out(Y), .ZHI_data_out(ZHI), .ZLO_data_out(ZLO),
        .R0_data_out(R0), .R1_data_out(R1), .R2_data_out(R2), .R3_data_out(R3), .R4_data_out(R4), .R5_data_out(R5), .R6_data_out(R6), .R7_data_out(R7),
        .R8_data_out(R8), .R9_data_out(R9), .R10_data_out(R10), .R11_data_out(R11), .R12_data_out(R12), .R13_data_out(R13), .R14_data_out(R14), .R15_data_out(R15),
        .INPORT_data_out(INPORT), .OUTPORT_data_out(OUTPORT), .INPORT_data_in(INPORT_data_in),
        .Rin_cs(Rin_cs), .Rout_cs(Rout_cs),

        // specific to T0 -> T2
        .PCout(PCout), .MARin(MARin), .IncrementPC(IncrementPC), .Zin(Zin),
        .ZLOout(ZLOout), .PCin(PCin), .Read(Read), .MDRin(MDRin),
        .Mdatain(MDin), .Mdataout(MDout),
        .MDRout(MDRout), .IRin(IRin),

        // specific to T3 -> T5
        .Yin(Yin),
        .Cout(Cout),
        .R15in(R15in)
    );

    initial
    begin
        INPORT_data_in = 32'h00;
        Clock = 0;
        forever #1 Clock = ~ Clock;
    end
endmodule