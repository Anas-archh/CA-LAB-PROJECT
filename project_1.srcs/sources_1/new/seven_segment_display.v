`timescale 1ns / 1ps

module seven_segment_display (
    input wire clk,             // main clock (we're assuming 100MHz)
    input wire reset,           // reset button or whatever

    // input digits to show (each one is a 4-bit BCD)
    input wire [3:0] digit_0,   // seconds (ones place)
    input wire [3:0] digit_1,   // seconds (tens place)
    input wire [3:0] digit_2,   // minutes (ones place)
    input wire [3:0] digit_3,   // strikes or game count thing

    // output to 7-seg display
    output reg [6:0] seg,       // segments a-g (0 = ON for common anode)
    output reg [3:0] an         // anodes to pick which display is active
);


// simple counter for multiplex timing
reg [15:0] count_mux;
reg [1:0] digit_select; // which digit we're currently showing
localparam MUX_RATE = 16'd12500; // 100MHz / 12500 ? 8kHz refresh (2kHz per digit)

// basically divides clock so we switch digits fast enough
always @(posedge clk) begin
    if (reset) begin
        count_mux <= 16'd0;
        digit_select <= 2'b00;
//        an = 4'b1111;
    end else begin
        if (count_mux == MUX_RATE - 1) begin
            count_mux <= 16'd0;
            digit_select <= digit_select + 2'b01; // move to next digit (0?1?2?3)
        end else begin
            count_mux <= count_mux + 16'd1;
        end
    end
end

// figure out which digit to show depending on digit_select
reg [3:0] current_digit;
always @(*) begin
    case (digit_select)
        2'b00: begin // first display = seconds ones
            current_digit = digit_0;
            an = 4'b1110; // turn on first display only
        end
        2'b01: begin // second display = seconds tens
            current_digit = digit_1;
            an = 4'b1101;
        end
        2'b10: begin // third display = minutes ones
            current_digit = digit_2;
            an = 4'b1011;
        end
        2'b11: begin // fourth display = strikes
            current_digit = digit_3;
            an = 4'b0111; 
        end
        default: begin 
            current_digit = 4'd10; // just show a dash if something's weird
            an = 4'b1111; // all off
        end
    endcase
end

// take the 4-bit value and map it to the 7-seg pattern
always @(*) begin
    case (current_digit)
        4'd0: seg = 7'b1000000;
        4'd1: seg = 7'b1111001;
        4'd2: seg = 7'b0100100;
        4'd3: seg = 7'b0110000;
        4'd4: seg = 7'b0011001;
        4'd5: seg = 7'b0010010;
        4'd6: seg = 7'b0000010;
        4'd7: seg = 7'b1111000;
        4'd8: seg = 7'b0000000;
        4'd9: seg = 7'b0010000;
        4'hA: seg = 7'b0001000; // 'A'
        4'hB: seg = 7'b0000011; // 'B' 
        4'hC: seg = 7'b1000110; // 'C'
        4'hD: seg = 7'b0100001; // 'D' 
        4'hE: seg = 7'b0000110; // 'E'
        4'hF: seg = 7'b0001110; // 'F'
        4'd10: seg = 7'b0111111; // dash (used if invalid)
    endcase
end

endmodule
