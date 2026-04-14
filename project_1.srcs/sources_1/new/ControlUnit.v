`timescale 1ns / 1ps
module ControlUnit (
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,
    output reg  RegWrite, MemRead, MemWrite,
    output reg  Branch, BranchNE, Jump, IsJALR,
    output reg  [1:0] ResultSrc,
    output reg  ALUSrc,
    output reg  [1:0] ALUOp
);
    always @(*) begin
        // Safe defaults
        RegWrite = 0; MemRead = 0; MemWrite = 0;
        Branch = 0; BranchNE = 0; Jump = 0; IsJALR = 0;
        ResultSrc = 2'b00; ALUSrc = 0; ALUOp = 2'b00;

        case (opcode)
            7'b0110011: begin // R-Type (ADD, SUB, AND, OR, XOR, SLT)
                RegWrite = 1; ALUSrc = 0; ResultSrc = 2'b00; ALUOp = 2'b10;
            end

            7'b0010011: begin // I-Type (ADDI, SLTI)
                RegWrite = 1; ALUSrc = 1; ResultSrc = 2'b00; ALUOp = 2'b11;
            end

            7'b0000011: begin // Load (LW)
                RegWrite = 1; ALUSrc = 1; ResultSrc = 2'b01; ALUOp = 2'b00; MemRead = 1;
            end

            7'b0100011: begin // Store (SW)
                ALUSrc = 1; MemWrite = 1; ALUOp = 2'b00;
            end

            7'b1100011: begin // B-Type (BEQ, BNE)
                ALUSrc = 0; ALUOp = 2'b01;
                if (funct3 == 3'b000) Branch   = 1; // BEQ
                if (funct3 == 3'b001) BranchNE = 1; // BNE
            end

            7'b1101111: begin // JAL
                RegWrite = 1; ResultSrc = 2'b10; Jump = 1;
            end

            7'b1100111: begin // JALR
                RegWrite = 1; ResultSrc = 2'b10; IsJALR = 1; ALUSrc = 1; ALUOp = 2'b11;
            end

            7'b0110111: begin // LUI (NEW)
                RegWrite = 1; ALUSrc = 1; ResultSrc = 2'b00; ALUOp = 2'b00;
                // ALUSrc=1 feeds imm into ALU; rs1 must be x0 in your test program
                // so ALU computes x0 + imm = imm, written to rd
            end

            default: ;
        endcase
    end
endmodule