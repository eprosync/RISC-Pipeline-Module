// General 128-bit register
// For stuff like this we would use a splitter to HI/LO wires
module register_128(input [127:0] D, input Clock, Clear, Write, output reg [127:0] Q);
    initial Q = 128'b0;

    always @ (posedge Clock)
    begin
        if (Clear) begin
            Q = 128'b0;
        end else if (Write) begin
            Q = D;
        end
    end
endmodule