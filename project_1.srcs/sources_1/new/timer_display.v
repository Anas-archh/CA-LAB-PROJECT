`timescale 1ns / 1ps

module timer_module(
    input wire clk,             // 100MHz System Clock
    input wire reset,           // Global Reset
    input wire timer_enable,    // High when the timer should count down
    input wire [7:0] initial_time_s, // 8-bit input (0-255) from FPGA switches

    // Outputs for 7-Segment Display
    output wire [3:0] timer_min_0,    // Minutes Units
    output wire [3:0] timer_sec_1,    // Seconds Tens
    output wire [3:0] timer_sec_0,    // Seconds Units
    output reg timeout_flag          // High when timer hits 0
);

reg [7:0] timer_seconds_reg;

always @(posedge clk) begin
    if (reset) begin
        timer_seconds_reg <= initial_time_s; // Initialize from switches
        timeout_flag <= 0;
    end else begin
        //timeout logic
        timeout_flag <= (timer_seconds_reg == 8'd0);
        if(timer_seconds_reg > 0 && timer_enable) begin
            timer_seconds_reg <= timer_seconds_reg - 1'b1;
        end
    end
end


assign timer_sec_0 = timer_seconds_reg % 10;
assign timer_sec_1 = (timer_seconds_reg / 10) % 6; // Handles 0-5 for seconds tens
assign timer_min_0 = timer_seconds_reg / 60;        // Handles minutes (up to 4 for 255s)



endmodule
