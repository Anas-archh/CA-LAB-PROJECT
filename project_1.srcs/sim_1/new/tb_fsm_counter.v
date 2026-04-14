//lab 5 test bench

`timescale 1ns / 1ps

module tb_fsm_counter;

    // Testbench signals
    reg         clk;
    reg         reset;
    reg  [15:0] switch_val;
    wire [31:0] led_writeData;
    wire        led_writeEn;
    wire        sw_readEn;
    wire        counting;
    wire        state;

    // Instantiate the DUT (Device Under Test)
    fsm_counter uut (
        .clk(clk),
        .reset(reset),
        .switch_val(switch_val),
        .led_writeData(led_writeData),
        .led_writeEn(led_writeEn),
        .sw_readEn(sw_readEn),
        .counting(counting),
        .currentState(state)
    );

    // Clock generation: 10ns period
    always begin
        #5 clk = ~clk;
    end

    initial begin
        // Initialize signals
        clk        = 0;
        reset      = 1;
        switch_val = 0;

        // Apply reset
        #20 reset = 0;

        // Give switch_val = 6 to trigger COUNTDOWN
        #10 switch_val = 16'd6;

        // Wait a few cycles, then set switch_val back to 0
        #100 switch_val = 16'd0;

        // Run long enough to see countdown complete
        #200;

        $finish;
    end

    // Monitor signals for debugging
    initial begin
        $monitor("Time=%0t | reset=%b | state=%b | counter=%d | switch_val=%d | led_writeData=%d | counting=%b",
                 $time, reset ,state, uut.counter, switch_val, led_writeData, counting);
    end

endmodule
