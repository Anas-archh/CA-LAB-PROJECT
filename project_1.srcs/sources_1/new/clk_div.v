`timescale 1ns / 1ps

module clk_div(
    input wire clk, 
    output reg clk_d);
    parameter div_value = 49999999; // to geta frequency of 1 hz
    reg [25:0] count; // width enough to hold 0 to div_value

    initial begin
        clk_d = 0;
        count = 0;
    end

    // Counter
    always @(posedge clk) begin
        if (count == div_value)begin
            count <= 0;       // reset count
            clk_d <= ~clk_d;
        end else
            count <= count + 1; // count up
            
    end

endmodule
