// General 32-bit register
module register_32(input [31:0] D, input Clock, Clear, Write, output reg [31:0] Q);
    initial Q = 32'b0;

    always @ (posedge Clock)
    begin
        if (Clear) begin
            Q = 32'b0;
        end else if (Write) begin
            Q = D;
        end
    end
endmodule