// Conditional Flip-Flop
// This is use for conditions with branching
// It can also be used for other things like comparators which I plan on adding at some point

`timescale 1ns / 1ps

// This is just a flip-flop...
module ff_logic(
        input Clk, D,
        output reg Q, Q_not
    );

    initial begin
        Q <= 0;
        Q_not <= 1;
    end

    always @ (Clk)
    begin
        Q <= D;
        Q_not <= !D;
    end
endmodule

module cff_decoder(input [1:0] in_decoder, output reg [3:0] out_decoder);
    always @ (*)
    begin
        case (in_decoder)
            2'b00 : out_decoder = 4'b0001;
            2'b01 : out_decoder = 4'b0010;
            2'b10 : out_decoder = 4'b0100;
            2'b11 : out_decoder = 4'b1000;
        endcase
        #1 $display("%0t [CON FF] %b -> %b", $time, in_decoder, out_decoder);
    end
endmodule

// We are taking in IR[20:19] to check for a conditional branch, which acts as the control signal for this
// Basically: brzr if zero, brnz if not, brpl if positive, brmi if negative
module cff_logic_32(
        input [31:0] BUS,
        input [31:0] IR,
        input IN,
        output OUT
    );

    // First up is to decode it to check what br we are doing
    wire [1:0] condition = IR[20:19];
    wire [3:0] decoder;
    cff_decoder decoder_logic(condition, decoder);

    // now to figure out what the branch wants, is the data negative, positive, etc
    assign is_zero = (BUS == 32'd0) ? 1 : 0;
    assign is_not_zero = !is_zero;
    assign is_positive = (BUS[31] == 0) ? 1 : 0;
    assign is_negative = !is_positive;
    assign branch_flag = (
        (is_zero & decoder[0]) |
        (is_not_zero & decoder[1]) |
        (is_positive & decoder[2]) |
        (is_negative & decoder[3])
    );

    ff_logic cff(IN, branch_flag, OUT);
endmodule