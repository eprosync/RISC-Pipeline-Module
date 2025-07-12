module op_not_64(input [63:0] Ain, output [63:0] Zout);
    genvar i;
    generate
        for (i=0; i<64; i=i+1) begin : loop
            assign Zout[i] = !Ain[i];
        end
    endgenerate
endmodule

module op_not_32(input [31:0] Ain, output [31:0] Zout);
    genvar i;
    generate
        for (i=0; i<32; i=i+1) begin : loop
            assign Zout[i] = !Ain[i];
        end
    endgenerate
endmodule