`timescale 1ns/1ps

module ALU32bit_tb;

    reg [31:0] A, B;
    reg [3:0] ALUctl;
    wire [31:0] ALUResult;
    wire Zero;

    // Instantiate DUT
    ALU32bit uut (
        .A(A),
        .B(B),
        .ALUctl(ALUctl),
        .ALUResult(ALUResult),
        .Zero(Zero)
    );

    initial begin
        // Monitor outputs
        $monitor("Time=%0t | ALUctl=%b | A=%h | B=%h | Result=%h | Zero=%b",
                  $time, ALUctl, A, B, ALUResult, Zero);

        // Test AND
        A = 32'hFFFF0000; B = 32'h0F0F0F0F; ALUctl = 4'b0000; #10;
        // Expected: ALUResult = 0x0F0F0000, Zero = 0

        // Test OR
        A = 32'hAAAA5555; B = 32'h12345678; ALUctl = 4'b0001; #10;
        // Expected: ALUResult = 0xBAFE577D, Zero = 0

        // Test XOR
        A = 32'hFFFFFFFF; B = 32'h0000FFFF; ALUctl = 4'b0010; #10;
        // Expected: ALUResult = 0xFFFF0000, Zero = 0

        // Test ADD
        A = 32'h00000010; B = 32'h00000020; ALUctl = 4'b0011; #10;
        // Expected: ALUResult = 0x00000030, Zero = 0

        // Test SUB
        A = 32'h00000030; B = 32'h00000010; ALUctl = 4'b0100; #10;
        // Expected: ALUResult = 0x00000020, Zero = 0

        // Test SLL
        A = 32'h00000001; B = 32'h00000004; ALUctl = 4'b0101; #10;
        // Expected: ALUResult = 0x00000010 (1 shifted left by 4), Zero = 0

        // Test SRL
        A = 32'h00000080; B = 32'h00000003; ALUctl = 4'b0110; #10;
        // Expected: ALUResult = 0x00000010 (128 >> 3), Zero = 0

        // Test Zero flag
        A = 32'h00000000; B = 32'h00000000; ALUctl = 4'b0000; #10;
        // Expected: ALUResult = 0x00000000, Zero = 1

        $finish;
    end

endmodule
