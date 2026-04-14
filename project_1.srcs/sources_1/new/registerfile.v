`timescale 1ns / 1ps

module RegisterFile(
    input clk,
    input rst,
    input WriteEnable,
    input [4:0] rs1,          // Source Register 1 Address [cite: 2608]
    input [4:0] rs2,          // Source Register 2 Address [cite: 2608]
    input [4:0] rd,           // Destination Register Address [cite: 2608]
    input [31:0] WriteData,   // Data to be written [cite: 2608]
    output [31:0] ReadData1,  // Data from rs1 [cite: 2609]
    output [31:0] ReadData2,   // Data from rs2 [cite: 2609]
    // Add this to your module's outputs at the top:
    output wire [31:0] a0_out
    );

    // Array of 32 registers, each 32 bits wide [cite: 2629]
    reg [31:0] registers [31:0];

    // Asynchronous Read Ports
    // Register x0 is hardwired to 0 
    assign ReadData1 = (rs1 == 5'b0) ? 32'b0 : registers[rs1];
    assign ReadData2 = (rs2 == 5'b0) ? 32'b0 : registers[rs2];


    integer i;
    always @(posedge clk) begin
        if (rst) begin
            // reset pressed? intialize the registers all the way from x0 to x31
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'b0;
            end
        end else if (WriteEnable && (rd != 5'b0)) begin
            // write data to rd (destination register)
            registers[rd] <= WriteData;
        end
    end
// Add this at the very bottom of the file (before endmodule):
assign a0_out = registers[10];
endmodule