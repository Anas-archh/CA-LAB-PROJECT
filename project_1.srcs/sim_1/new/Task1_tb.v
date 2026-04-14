`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/03/2026 09:55:54 PM
// Design Name: 
// Module Name: Task1_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
/////////////////////////////////////`timescale 1ns / 1ps
module Task1_tb();
    reg clk, rst;
    reg [31:0] inst;
    reg PCSrc;
    
    wire [31:0] PC, next_PC, PC_plus_4, branch_target, imm;
    
    // Instantiate Modules
    ProgramCounter u_pc (.clk(clk), .rst(rst), .next_PC(next_PC), .PC(PC));
    pcAdder u_pcAdd (.PC(PC), .PC_plus_4(PC_plus_4));
    immGen u_immGen (.inst(inst), .imm(imm));
    branchAdder u_brAdd (.PC(PC), .imm(imm), .branch_target(branch_target));
    mux2 u_mux (.d0(PC_plus_4), .d1(branch_target), .sel(PCSrc), .y(next_PC));

    always #5 clk = ~clk; // 10ns Clock

    initial begin
        clk = 0; rst = 1; PCSrc = 0; inst = 32'b0;
        #20 rst = 0; // Release reset
        
        // Test 1: Normal PC+4 Execution
        // Give it an I-Type Instruction: ADDI x5, x0, 10
        // Inst = 000000001010_00000_000_00101_0010011
        #10 inst = 32'b000000001010_00000_000_00101_0010011; 
        PCSrc = 0; // Don't branch
        
        // Test 2: Branch Execution
        // Give it a B-Type Instruction: BEQ x1, x2, offset = 8 (which is 4 in unshifted bits)
        // immGen should extract 4. branchAdder will shift to 8. Target = PC + 8.
        #20 inst = 32'b0000000_00010_00001_000_0100_1100011;
        PCSrc = 1; // Take the branch
        
        #20 $finish;
    end
endmodule/////////////////////////////////////////////
