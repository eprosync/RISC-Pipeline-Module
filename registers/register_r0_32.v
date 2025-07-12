module register_R0_32(input [31:0] D, input Clock, Clear, Write, BAout, output [31:0] Q);
    wire [31:0] Q_copy;
    register_32 R0(D, Clock, Clear, Write, Q_copy);
    assign Q = ({32{!BAout}} & Q_copy);
endmodule