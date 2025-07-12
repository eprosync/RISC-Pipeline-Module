`timescale 1ns / 1ps

module alu_tb;
  // Declare inputs and outputs
  reg Clock, Clear;
  reg [31:0] A_in, B_in;
  reg [4:0] Control;
  wire [63:0] C_out;

  // Instantiate module under test
  ALU_32 dut(
    .Clock(Clock),
    .Clear(Clear),
    .Control(Control),
    .reg_A(A_in),
    .reg_B(B_in),
    .reg_C(C_out)
  );

  // Clock Generator
  initial Clock = 0;
  always #1 Clock = ~Clock;

  task apply_op;
    input [31:0] A, B;
    input [4:0] ctrl;
    begin
      A_in = A;
      B_in = B;
      Control = ctrl;
      #2;
    end
  endtask

  // Initialize inputs
  initial begin
    Clear = 0;

    // Basic operations
    apply_op(32'h00000004, 32'h00000004, 5'b00011); // add -> 0x8
    apply_op(32'h00000008, 32'h00000004, 5'b00100); // sub -> 0x4
    apply_op(32'hFFFFFFFF, 32'h0000000F, 5'b00101); // and -> 0xF
    apply_op(32'hF0F0F0F0, 32'h0F0F0F0F, 5'b00110); // or -> 0xFFFFFFFF

    // Shift operations
    apply_op(32'h80000000, 32'h00000001, 5'b00111); // shr -> 0x40000000
    apply_op(32'h80000000, 32'h00000001, 5'b01000); // shra -> 0xFFFE0000
    apply_op(32'h00000001, 32'h00000001, 5'b01001); // shl -> 0x00000002
    apply_op(32'hA5A5A5A5, 32'h00000004, 5'b01010); // ror -> 0x5A5A5A5A
    apply_op(32'h5A5A5A5A, 32'h00000004, 5'b01011); // rol -> 0xA5A5A5A5

    // Multiply and divide
    apply_op(32'd6, 32'd7, 5'b01111); // mul -> 42 -> 0x2A
    apply_op(32'd42, 32'd6, 5'b10000); // div -> 7 -> 0x7

    // Unary ops
    apply_op(32'd0, 32'd1234, 5'b10001); // neg -> 0xFFFFFB2E -> -1234
    apply_op(32'd0, 32'hAAAAAAAA, 5'b10010); // not -> 0x55555555

    // Edge cases
    apply_op(32'hFFFFFFFF, 32'h00000001, 5'b00011); // add (overflow) -> 0x0 
    apply_op(32'h80000000, 32'h00000001, 5'b00100); // sub (underflow) -> 0x7FFFFFFF
    apply_op(32'd123, 32'd0, 5'b10000); // div by zero -> 0xFFFFFFFF...

    #20;
    $finish;
  end
endmodule