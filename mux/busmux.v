module busmux_encoder(
        // general registers
        input R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15,
        // special registers
        input HI, LO, ZHI, ZLO, PC, MDR, InPort, C,
        output reg [4:0] Control
    );

    always @ (*) begin
		  Control = 5'b00000;
        if (R0) Control = 5'b00000;
        else if (R1) Control = 5'b00001;
        else if (R2) Control = 5'b00010;
        else if (R3) Control = 5'b00011;
        else if (R4) Control = 5'b00100;
        else if (R5) Control = 5'b00101;
        else if (R6) Control = 5'b00110;
        else if (R7) Control = 5'b00111;
        else if (R8) Control = 5'b01000;
        else if (R9) Control = 5'b01001;
        else if (R10) Control = 5'b01010;
        else if (R11) Control = 5'b01011;
        else if (R12) Control = 5'b01100;
        else if (R13) Control = 5'b01101;
        else if (R14) Control = 5'b01110;
        else if (R15) Control = 5'b01111;
        else if (HI) Control = 5'b10000;
        else if (LO) Control = 5'b10001;
        else if (ZHI) Control = 5'b10010;
        else if (ZLO) Control = 5'b10011;
        else if (PC) Control = 5'b10100;
        else if (MDR) Control = 5'b10101;
        else if (InPort) Control = 5'b10110;
        else if (C) Control = 5'b10111;
    end

endmodule

module busmux(
        // general registers
        input [31:0] R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15,
        // special registers
        input [31:0] HI, LO, ZHI, ZLO, PC, MDR, InPort, C,
        input [4:0] Control,
        output [31:0] BusMuxOut
    );

    reg [31:0] MuxOut;

    always @ (*) begin
        $display("%0t [BusMux] State %b", $time, Control);
        case(Control)
            5'b00000: MuxOut = R0;
            5'b00001: MuxOut = R1;
            5'b00010: MuxOut = R2;
            5'b00011: MuxOut = R3;
            5'b00100: MuxOut = R4;
            5'b00101: MuxOut = R5;
            5'b00110: MuxOut = R6;
            5'b00111: MuxOut = R7;
            5'b01000: MuxOut = R8;
            5'b01001: MuxOut = R9;
            5'b01010: MuxOut = R10;
            5'b01011: MuxOut = R11;
            5'b01100: MuxOut = R12;
            5'b01101: MuxOut = R13;
            5'b01110: MuxOut = R14;
            5'b01111: MuxOut = R15;
            5'b10000: MuxOut = HI;
            5'b10001: MuxOut = LO;
            5'b10010: MuxOut = ZHI;
            5'b10011: MuxOut = ZLO;
            5'b10100: MuxOut = PC;
            5'b10101: MuxOut = MDR;
            5'b10110: MuxOut = InPort;
            5'b10111: MuxOut = C;
            default: MuxOut = 32'h0;
        endcase
    end

    assign BusMuxOut = MuxOut;
endmodule