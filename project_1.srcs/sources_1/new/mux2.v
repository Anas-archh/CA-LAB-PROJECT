`timescale 1ns / 1ps
module mux2 (
    input wire [31:0] d0,  // PC + 4
    input wire [31:0] d1,  // Branch Target
    input wire sel,        // PCSrc
    output wire [31:0] y
);
    assign y = sel ? d1 : d0;
endmodule