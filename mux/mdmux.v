module mdmux(
        input [31:0] BusMuxOut,
        input [31:0] Mdatain,
        input Read,
        output reg [31:0] MDRin
    );

    always @ (*) begin
        if (Read) begin
            MDRin = Mdatain;
        end else begin
            MDRin = BusMuxOut;
        end
    end
endmodule