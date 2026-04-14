`timescale 1ns / 1ps
module bcd_converter(
    input  wire [15:0] value,
    output reg  [3:0]  digit_0,
    output reg  [3:0]  digit_1,
    output reg  [3:0]  digit_2,
    output reg  [3:0]  digit_3
);
    reg [15:0] temp;
    always @(*) begin
        temp    = value;
        digit_3 = 4'd0;
        digit_2 = 4'd0;
        digit_1 = 4'd0;
        digit_0 = 4'd0;
        // thousands
        if      (temp >= 16'd9000) begin digit_3 = 4'd9; temp = temp - 16'd9000; end
        else if (temp >= 16'd8000) begin digit_3 = 4'd8; temp = temp - 16'd8000; end
        else if (temp >= 16'd7000) begin digit_3 = 4'd7; temp = temp - 16'd7000; end
        else if (temp >= 16'd6000) begin digit_3 = 4'd6; temp = temp - 16'd6000; end
        else if (temp >= 16'd5000) begin digit_3 = 4'd5; temp = temp - 16'd5000; end
        else if (temp >= 16'd4000) begin digit_3 = 4'd4; temp = temp - 16'd4000; end
        else if (temp >= 16'd3000) begin digit_3 = 4'd3; temp = temp - 16'd3000; end
        else if (temp >= 16'd2000) begin digit_3 = 4'd2; temp = temp - 16'd2000; end
        else if (temp >= 16'd1000) begin digit_3 = 4'd1; temp = temp - 16'd1000; end
        // hundreds
        if      (temp >= 16'd900) begin digit_2 = 4'd9; temp = temp - 16'd900; end
        else if (temp >= 16'd800) begin digit_2 = 4'd8; temp = temp - 16'd800; end
        else if (temp >= 16'd700) begin digit_2 = 4'd7; temp = temp - 16'd700; end
        else if (temp >= 16'd600) begin digit_2 = 4'd6; temp = temp - 16'd600; end
        else if (temp >= 16'd500) begin digit_2 = 4'd5; temp = temp - 16'd500; end
        else if (temp >= 16'd400) begin digit_2 = 4'd4; temp = temp - 16'd400; end
        else if (temp >= 16'd300) begin digit_2 = 4'd3; temp = temp - 16'd300; end
        else if (temp >= 16'd200) begin digit_2 = 4'd2; temp = temp - 16'd200; end
        else if (temp >= 16'd100) begin digit_2 = 4'd1; temp = temp - 16'd100; end
        // tens
        if      (temp >= 16'd90) begin digit_1 = 4'd9; temp = temp - 16'd90; end
        else if (temp >= 16'd80) begin digit_1 = 4'd8; temp = temp - 16'd80; end
        else if (temp >= 16'd70) begin digit_1 = 4'd7; temp = temp - 16'd70; end
        else if (temp >= 16'd60) begin digit_1 = 4'd6; temp = temp - 16'd60; end
        else if (temp >= 16'd50) begin digit_1 = 4'd5; temp = temp - 16'd50; end
        else if (temp >= 16'd40) begin digit_1 = 4'd4; temp = temp - 16'd40; end
        else if (temp >= 16'd30) begin digit_1 = 4'd3; temp = temp - 16'd30; end
        else if (temp >= 16'd20) begin digit_1 = 4'd2; temp = temp - 16'd20; end
        else if (temp >= 16'd10) begin digit_1 = 4'd1; temp = temp - 16'd10; end
        // ones
        digit_0 = temp[3:0];
    end
endmodule