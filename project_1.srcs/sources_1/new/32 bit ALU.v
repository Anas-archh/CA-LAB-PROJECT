module ALU32bit (
    input [31:0] A, B,
    input [3:0] ALUctl,
    output reg [31:0] ALUResult,
    output Zero
);
    wire [31:0] cascaded_result;
    wire [31:0] shift_result;

    // 1. Logic & Arithmetic (The cascaded part)
    // Instantiate your 32 1-bit ALUs here. 
    wire [31:0] carryWire;
    wire i_cin = (ALUctl == 4'b0100) ? 1'b1 : 1'b0; // initial carry in logic for addition or subtraction.
    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : alu_slice
            ALU1bit bit_slice (
                .A(A[i]),
                .B(B[i]),
                .carryIn(i == 0 ? i_cin: carryWire[i-1]), // Link carry chain
                .ALUctl(ALUctl),
                .Result(cascaded_result[i]),
                .carryOut(carryWire[i])
            );
        end
    endgenerate
    
    // 2. Shifting Logic (32-bit behavioral)
    // In RISC-V, SLL/SRL often use the lower 5 bits of B (the shift amount)
    assign shift_result = (ALUctl == 4'b0101) ? (A << B[4:0]) : // SLL, risc 5 architecture uses lower 5 bits of rs2 for shifting
                          (ALUctl == 4'b0110) ? (A >> B[4:0]) : // SRL
                          32'b0;

    // 3. The Final Output Mux
    always @(*) begin
        if (ALUctl == 4'b0101 | ALUctl == 4'b0110) // If the op code is a shift
            ALUResult = shift_result;
        else
            ALUResult = cascaded_result; // Use the 1-bit chain result
    end

    assign Zero = (ALUResult == 0);
endmodule