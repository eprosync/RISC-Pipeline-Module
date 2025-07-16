`timescale 1ns/1ps

module datapath_tb;
    reg Clock;

    datapath DUT(
        .Clock(Clock),
    );

    initial
    begin
        Clock = 0;
        forever #1 Clock = ~ Clock;
    end
endmodule