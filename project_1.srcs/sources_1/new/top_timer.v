`timescale 1ns / 1ps
module top_timer(
    input clk,       // 100MHz from the board
    input rst,
    output reg slow_clk  // New slow clock for the CPU
);
    reg [24:0] count;
    
    always @(posedge clk) begin
        if (rst) begin
            count <= 0;
            slow_clk <= 0;
        end else if (count == 4_999_999) begin // Toggles 10 times a second
            count <= 0;
            slow_clk <= ~slow_clk;
        end else begin
            count <= count + 1;
        end
    end
endmodule