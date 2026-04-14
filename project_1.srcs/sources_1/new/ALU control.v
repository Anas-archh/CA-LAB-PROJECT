`timescale 1ns / 1ps
module ALUControl (
    input  wire [1:0] ALUOp,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,
    output reg  [3:0] Operation
);
    always @(*) begin
        case (ALUOp)
            2'b00: Operation = 4'b0010; // LW/SW: ADD

            2'b01: Operation = 4'b0110; // Branch: SUB

            2'b10: begin // R-Type
                case (funct3)
                    3'b000: Operation = (funct7[5]) ? 4'b0110 : 4'b0010; // SUB / ADD
                    3'b111: Operation = 4'b0000; // AND
                    3'b110: Operation = 4'b0001; // OR
                    3'b100: Operation = 4'b0011; // XOR  (NEW)
                    3'b010: Operation = 4'b0111; // SLT  (NEW)
                    default: Operation = 4'b0010;
                endcase
            end

            2'b11: begin // I-Type
                case (funct3)
                    3'b000: Operation = 4'b0010; // ADDI
                    3'b010: Operation = 4'b0111; // SLTI (NEW)
                    default: Operation = 4'b0010;
                endcase
            end

            default: Operation = 4'b0010;
        endcase
    end
endmodule