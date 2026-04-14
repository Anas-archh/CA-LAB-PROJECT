`timescale 1ns / 1ps
module top_lab9 (
    input  wire        clk,
    input  wire        rst,
    input  wire [15:0] sw,
    output wire [15:0] led
);
    // sw[6:0]  = opcode
    // sw[9:7]  = funct3
    // sw[10]   = funct7_5

    wire RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg, Branch;
    wire [1:0] ALUOp;
    wire [3:0] ALUControl;

    MainControl mc (
        .opcode  (sw[6:0]),
        .RegWrite(RegWrite),
        .ALUSrc  (ALUSrc),
        .MemRead (MemRead),
        .MemWrite(MemWrite),
        .MemtoReg(MemtoReg),
        .Branch  (Branch),
        .ALUOp   (ALUOp)
    );

    ALUControl ac (
        .ALUOp    (ALUOp),
        .funct3   (sw[9:7]),
        .funct7_5 (sw[10]),
        .ALUControl(ALUControl)
    );

    // Map outputs to LEDs for visual verification
    // LED[0]   = RegWrite
    // LED[1]   = ALUSrc
    // LED[2]   = MemRead
    // LED[3]   = MemWrite
    // LED[4]   = MemtoReg
    // LED[5]   = not working on fpga
    // LED[7:6] = ALUOp
    // LED[8] = Branch
    // LED[11:9] = not used cuz led[10] faulty on board
    // LED[15:12]= ALUControl
    assign led[0]    = RegWrite;
    assign led[1]    = ALUSrc;
    assign led[2]    = MemRead;
    assign led[3]    = MemWrite;
    assign led[4]    = MemtoReg;
    assign led[5]    = 1'b0;
    assign led[7:6]  = ALUOp;
    assign led[8] = Branch;
    assign led[15:12] = ALUControl;
    assign led[11:9]= 4'b0;

endmodule