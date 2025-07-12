// General 64-bit register
module register_64(input [63:0] D, input Clock, Clear, Write, output reg [63:0] Q);
    initial Q = 64'b0;

    always @ (posedge Clock)
    begin
        if (Clear) begin
            Q = 64'b0;
        end else if (Write) begin
            Q = D;
        end
    end
endmodule