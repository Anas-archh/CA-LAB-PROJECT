`timescale 1ns / 1ps
module immGen (
    input wire [31:0] inst,
    output reg [31:0] imm
);
    wire [6:0] opcode = inst[6:0];
    
    always @(*) begin
        case (opcode)
            // I-Type (ADDI, LW, JALR) - No shift required
            7'b0010011, 7'b0000011, 7'b1100111: imm = {{20{inst[31]}}, inst[31:20]};
            
            // S-Type (SW) - No shift required
            7'b0100011: imm = {{20{inst[31]}}, inst[31:25], inst[11:7]};
            
            // B-Type (BEQ, BNE) -> FIXED: Removed the trailing 1'b0 to prevent double-shifting
            7'b1100011: imm = {{21{inst[31]}}, inst[7], inst[30:25], inst[11:8]};
            
            // J-Type (JAL) -> FIXED: Removed the trailing 1'b0 to prevent double-shifting
            7'b1101111: imm = {{13{inst[31]}}, inst[19:12], inst[20], inst[30:21]};
            
            default: imm = 32'b0;
        endcase
    end
endmodule