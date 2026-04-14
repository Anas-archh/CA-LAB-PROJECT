`timescale 1ns / 1ps
module leds(
    input         clk,
    input         rst,
    input  [31:0] writeData,
    input         writeEnable,
    input         readEnable,       // kept for port compatibility, unused
    input  [29:0] memAddress,       // kept for port compatibility, unused
    output reg [31:0] readData,     // kept for port compatibility, always 0
    output reg [15:0] leds
);

    // LEDs are write-only output device.
    // readData is always 0. readEnable and memAddress are unused.
    always @(posedge clk) begin
        if (rst) begin
            leds     <= 16'b0;
            readData <= 32'b0;      // this is not supposed to be included in this module
        end else if (writeEnable) begin
            leds     <= writeData[15:0];
            readData <= 32'b0;      // this is not supposed to be included in this module
        end
    end

endmodule