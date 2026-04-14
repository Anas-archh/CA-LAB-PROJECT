module ALU1bit (
    input A, B, carryIn,
    input [3:0] ALUctl,
    output reg Result,
    output carryOut
);
    wire sum;
    assign carryOut = (ALUctl == 4'b0100) ? (A & ~B)|(~B & carryIn) | (A & carryIn) : (A & B)|(B & carryIn) | (A & carryIn);
    assign sum = ALUctl == 4'b0100 ? A^~B^carryIn : A^B^carryIn;
    always @(*) begin
        case (ALUctl)
            4'b0000: Result = A & B;      // AND
            4'b0001: Result = A | B;      // OR
            4'b0010: Result = A ^ B;      // XOR
            4'b0011: Result = sum;        // ADD
            4'b0100: Result = sum;      // SUB
            4'b0101: Result = B << 1;     // SLL, using verilogs behavorial operator in top module for this 
            4'b0110: Result = B >> 1;     // SRL, using verilogs behavorial operator in top module for this 
            default: Result = 0;
        endcase
    end
endmodule
