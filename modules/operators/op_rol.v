module op_rol_64(input [63:0] Ain, Bin, output reg [63:0] Zout);
    always @ (*) begin
        Zout = (Ain << Bin) | (Ain >> (64 - Bin));
    end
endmodule

module op_rol_32(input [31:0] Ain, Bin, output reg [31:0] Zout);
    always @ (*) begin
        Zout = (Ain << Bin) | (Ain >> (32 - Bin));
    end
endmodule