`timescale 1ns / 1ps
module ALU (
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire [3:0]  ALUControl,
    output reg  [31:0] Result,
    output wire        Zero
);
    // ALUControl encoding:
    // 4'b0000 = AND
    // 4'b0001 = OR
    // 4'b0010 = ADD
    // 4'b0011 = XOR  (NEW)
    // 4'b0110 = SUB
    // 4'b0111 = SLT  (NEW)

    always @(*) begin
        case (ALUControl)
            4'b0000: Result = A & B;
            4'b0001: Result = A | B;
            4'b0010: Result = A + B;
            4'b0011: Result = A ^ B;                                      // XOR
            4'b0110: Result = A - B;
            4'b0111: Result = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0; // SLT/SLTI
            default: Result = 32'b0;
        endcase
    end

    assign Zero = (Result == 32'b0);
endmodule