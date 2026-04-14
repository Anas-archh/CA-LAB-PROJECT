`timescale 1ns / 1ps

module DataMemory(
    input wire clk,
    input wire MemWrite,
    input wire MemRead,
    input wire [31:0] address,
    input wire [31:0] write_data,
    output reg [31:0] read_data
);

    // Memory array: 256 words (each 32 bits wide)
    reg [31:0] memory [0:255];

    integer i;
    initial begin
        for (i = 0; i < 256; i = i + 1) begin
            memory[i] = 32'b0;
        end
    end

    // Write operation (Synchronous - happens on clock edge)
    always @(posedge clk) begin
        if (MemWrite) begin
            // address[9:2] converts the byte address to a word index
            memory[address[9:2]] <= write_data;
        end
    end

    // Read operation (Asynchronous - happens immediately)
    always @(*) begin
        if (MemRead) begin
            read_data = memory[address[9:2]];
        end else begin
            read_data = 32'b0;
        end
    end

endmodule