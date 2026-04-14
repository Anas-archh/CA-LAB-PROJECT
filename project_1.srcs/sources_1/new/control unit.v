`timescale 1ns / 1ps
module MainControl (
    input  [6:0] opcode,
    output reg   RegWrite,
    output reg   ALUSrc,
    output reg   MemRead,
    output reg   MemWrite,
    output reg   MemtoReg,
    output reg   Branch,
    output reg [1:0] ALUOp
);

    // RISC-V opcode definitions
    localparam R_TYPE  = 7'b0110011; // ADD, SUB, SLL, SRL, AND, OR, XOR
    localparam I_TYPE  = 7'b0010011; // ADDI
    localparam LOAD    = 7'b0000011; // LW, LH, LB
    localparam STORE   = 7'b0100011; // SW, SH, SB
    localparam BRANCH  = 7'b1100011; // BEQ

    always @(*) begin
        // safe defaults - prevent latches
        RegWrite = 0;
        ALUSrc   = 0;
        MemRead  = 0;
        MemWrite = 0;
        MemtoReg = 0;
        Branch   = 0;
        ALUOp    = 2'b00;

        case (opcode)
            R_TYPE: begin
                RegWrite = 1;
                ALUSrc   = 0;   // use register value, not immediate
                MemRead  = 0;
                MemWrite = 0;
                MemtoReg = 0;   // write ALU result to register
                Branch   = 0;
                ALUOp    = 2'b10; // ALU control decides operation via funct3/funct7
            end

            I_TYPE: begin
                RegWrite = 1;
                ALUSrc   = 1;   // use immediate value
                MemRead  = 0;
                MemWrite = 0;
                MemtoReg = 0;   // write ALU result to register
                Branch   = 0;
                ALUOp    = 2'b10; // ALU control decides via funct3
            end

            LOAD: begin
                RegWrite = 1;
                ALUSrc   = 1;   // use immediate as offset
                MemRead  = 1;
                MemWrite = 0;
                MemtoReg = 1;   // write memory data to register
                Branch   = 0;
                ALUOp    = 2'b00; // always ADD for address calculation
            end

            STORE: begin
                RegWrite = 0;   // nothing written to register
                ALUSrc   = 1;   // use immediate as offset
                MemRead  = 0;
                MemWrite = 1;
                MemtoReg = 0;   // don't care, but set to 0 safely
                Branch   = 0;
                ALUOp    = 2'b00; // always ADD for address calculation
            end

            BRANCH: begin
                RegWrite = 0;   // nothing written to register
                ALUSrc   = 0;   // compare two registers
                MemRead  = 0;
                MemWrite = 0;
                MemtoReg = 0;   // don't care, but set to 0 safely
                Branch   = 1;
                ALUOp    = 2'b01; // always SUB for comparison
            end

            default: begin
                // unknown opcode - all signals off
                RegWrite = 0;
                ALUSrc   = 0;
                MemRead  = 0;
                MemWrite = 0;
                MemtoReg = 0;
                Branch   = 0;
                ALUOp    = 2'b00;
            end
        endcase
    end

endmodule