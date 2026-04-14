`timescale 1ns / 1ps

module RegisterFile_tb;

    // Testbench signals
    reg clk;
    reg rst;
    reg WriteEnable;
    reg [4:0] rs1;
    reg [4:0] rs2;
    reg [4:0] rd;
    reg [31:0] WriteData;
    wire [31:0] ReadData1;
    wire [31:0] ReadData2;

    // Instantiate the DUT (Device Under Test)
    RegisterFile uut (
        .clk(clk),
        .rst(rst),
        .WriteEnable(WriteEnable),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .WriteData(WriteData),
        .ReadData1(ReadData1),
        .ReadData2(ReadData2)
    );

    // Clock generation: 10 ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Stimulus
    initial begin
        // Initialize inputs
        rst = 1;
        WriteEnable = 0;
        rs1 = 0;
        rs2 = 0;
        rd = 0;
        WriteData = 0;

        // Apply reset
        #10;
        rst = 0;

        // Write 32'hA5A5A5A5 into register 5
        @(posedge clk);
        WriteEnable = 1;
        rd = 5;
        WriteData = 32'hA5A5A5A5;

        @(posedge clk);
        WriteEnable = 0;

        // Read back from register 5
        rs1 = 5;
        rs2 = 0; // should always read 0
        #10;
        $display("ReadData1 (reg5) = %h, ReadData2 (reg0) = %h", ReadData1, ReadData2);

        // Write 32'hDEADBEEF into register 10
        @(posedge clk);
        WriteEnable = 1;
        rd = 10;
        WriteData = 32'hDEADBEEF;

        @(posedge clk);
        WriteEnable = 0;

        // Read back from register 10
        rs1 = 10;
        rs2 = 5;
        #10;
        $display("ReadData1 (reg10) = %h, ReadData2 (reg5) = %h", ReadData1, ReadData2);

        // Write 32'hDEADBEEF into register 10 with writeEnable = 0
        @(posedge clk);
        WriteEnable = 0;
        rd = 10;
        WriteData = 32'hDDDDDDDD;

        @(posedge clk);
        WriteEnable = 0;

        // Read back from register 10, value should be unchanged
        rs1 = 10;
        rs2 = 5;
        #10;
        $display("ReadData1 (reg10) = %h, ReadData2 (reg5) = %h", ReadData1, ReadData2);

        // Try writing to register 0 (should remain 0)
        @(posedge clk);
        WriteEnable = 1;
        rd = 0;
        WriteData = 32'hFFFFFFFF;

        @(posedge clk);
        WriteEnable = 1;

        rs1 = 0;
        #10;
        $display("ReadData1 (reg0) = %h (should be 0)", ReadData1);

        // Finish simulation
        #20;
        $finish;
    end

endmodule
