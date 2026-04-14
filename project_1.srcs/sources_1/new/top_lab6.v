`timescale 1ns / 1ps

module top_lab6(
    input  wire        clk,
    input  wire        reset,
    input  wire [5:0] A,          // physical switches
    input  wire [5:0] B,          // physical switches
    input wire  [3:0] ALUctl,
    
    output wire [6:0]  seg,         // 7-segment segments
    output wire [3:0]  an,          // 7-segment 
    output wire Zero
    );
    
    // wires between modules 
    wire [31:0] ALUResult;
    wire [3:0] digit_0, digit_1, digit_2, digit_3;
    
    
    ALU32bit ALu_inst(
        .A({26'b0, A}), 
        .B({26'b0, B}),
        .ALUctl(ALUctl),
        .ALUResult(ALUResult),
        .Zero(Zero)
    );
        
    bcd_converter bcd_inst (
        .value  (ALUResult),
        .digit_0(digit_0),
        .digit_1(digit_1),
        .digit_2(digit_2),
        .digit_3(digit_3)
    );

    // seven segment display 
    seven_segment seg_inst (
        .clk    (clk),
        .reset  (reset),
        .digit_0(digit_0),
        .digit_1(digit_1),
        .digit_2(digit_2),
        .digit_3(digit_3),
        .seg    (seg),
        .an     (an)
    );

    
endmodule
