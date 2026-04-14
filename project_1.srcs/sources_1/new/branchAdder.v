`timescale 1ns / 1ps
module branchAdder (
    input wire [31:0] PC,
    input wire [31:0] imm,
    output wire [31:0] branch_target
);
    assign branch_target = PC + (imm << 1);
endmodule