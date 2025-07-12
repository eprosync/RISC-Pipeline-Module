// You can use this to slow things down, this is for like when I am testing on an FPGA with its own quartz oscillators
module clk_div(
        input Clk,
        output reg ClkDiv
    );

    parameter Divisor = 28'd50; // divide by 50
    reg [27:0] counter = 28'b0;

    always @ (posedge Clk)
    begin
        counter <= counter + 28'b1;
        if (counter >= (Divisor-1)) counter <= 28'b0;
        ClkDiv <= (counter < Divisor/2) ? 1'b1 : 1'b0;
    end
endmodule