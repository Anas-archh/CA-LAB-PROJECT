`timescale 1ns / 1ps
module tb_control;
    reg  [6:0] opcode;
    reg  [2:0] funct3;
    reg        funct7_5;
    
    wire RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg, Branch;
    wire [1:0] ALUOp;
    wire [3:0] ALUControl;
    
    MainControl mc (
        .opcode  (opcode),
        .RegWrite(RegWrite), .ALUSrc(ALUSrc),
        .MemRead (MemRead),  .MemWrite(MemWrite),
        .MemtoReg(MemtoReg), .Branch  (Branch),
        .ALUOp   (ALUOp)
    );
    ALUControl ac (
        .ALUOp   (ALUOp),
        .funct3  (funct3),
        .funct7_5(funct7_5),
        .ALUControl(ALUControl)
    );
    
    task check;
        input [6:0] op;
        input [2:0] f3;
        input       f7;
        input [3:0] expected_alu;
        input       exp_rw, exp_asrc, exp_mr, exp_mw, exp_m2r, exp_br;
        begin
            opcode = op; funct3 = f3; funct7_5 = f7;
            #10;
            $display("opcode=%b funct3=%b | RW=%b ASrc=%b MR=%b MW=%b M2R=%b Br=%b ALUCtl=%b | ALUCtl exp=%b %s",
                op, f3, RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg, Branch, ALUControl,
                expected_alu, (ALUControl==expected_alu)?"PASS":"FAIL");
        end
    endtask
    
    initial begin
        $display("=== Control Path Testbench ===");
        // R-type: ADD
        check(7'b0110011, 3'b000, 1'b0, 4'b0011, 1,0,0,0,0,0);
        // R-type: SUB
        check(7'b0110011, 3'b000, 1'b1, 4'b0100, 1,0,0,0,0,0);
        // R-type: SLL
        check(7'b0110011, 3'b001, 1'b0, 4'b0101, 1,0,0,0,0,0);
        // R-type: SRL
        check(7'b0110011, 3'b101, 1'b0, 4'b0110, 1,0,0,0,0,0);
        // R-type: AND
        check(7'b0110011, 3'b111, 1'b0, 4'b0000, 1,0,0,0,0,0);
        // R-type: OR
        check(7'b0110011, 3'b110, 1'b0, 4'b0001, 1,0,0,0,0,0);
        // R-type: XOR
        check(7'b0110011, 3'b100, 1'b0, 4'b0010, 1,0,0,0,0,0);
        // I-type: ADDI
        check(7'b0010011, 3'b000, 1'b0, 4'b0011, 1,1,0,0,0,0);
        // LOAD: LW
        check(7'b0000011, 3'b010, 1'b0, 4'b0011, 1,1,1,0,1,0);
        // STORE: SW
        check(7'b0100011, 3'b010, 1'b0, 4'b0011, 0,1,0,1,0,0);
        // BRANCH: BEQ
        check(7'b1100011, 3'b000, 1'b0, 4'b0100, 0,0,0,0,0,1);
        $finish;
    end
endmodule