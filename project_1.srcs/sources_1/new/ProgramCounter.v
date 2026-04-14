`timescale 1ns / 1ps
module ProgramCounter (
    input wire clk,
    input wire rst,
    input wire [31:0] next_PC,
    output reg [31:0] PC
);
    always @(posedge clk or posedge rst) begin
        if (rst) 
            PC <= 32'h00000000;
        else 
            PC <= next_PC;
    end
endmodule