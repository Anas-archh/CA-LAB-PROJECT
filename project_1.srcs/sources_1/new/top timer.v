`timescale 1ns / 1ps

module top_lab5 (
    input  wire        clk,
    input  wire        reset,
    input  wire [15:0] sw,          // physical switches
    input wire         sw_readEn,           // controlling the readEnable from board so state

    output wire [6:0]  seg,         // 7-segment segments
    output wire [3:0]  an          // 7-segment anodes
);
    
    // wires between modules 
    wire [31:0] sw_readData;        // takes the value of readData from switched and passes into fsm
    wire [31:0] led_writeData;      // takes the value of counter output from fsm and pass into led module
    wire        led_writeEn;        // flag jo led module mai jaiga.
    wire [15:0] counter_val;        // current FSM counter value, yeh led module mai se aiga
    
    
    // switches module 
    switches sw_inst (
        .clk        (clk),
        .rst        (reset),
        .btns       (16'd0),        // no buttons used
        .writeData  (32'd0),        // not to be written
        .writeEnable(1'b0),
        .readEnable (sw_readEn),
        .memAddress (30'd0),
        .switches   (sw),           // physical switches go here
        .readData   (sw_readData)
    );
    
    // clock divider to run counter at a freq of 1hz
    wire clk_d;

    clk_div clk_div_inst (
        .clk (clk),
        .clk_d (clk_d)
    );

    // FSM + counter 
    fsm_counter fsm_inst (
        .clk          (clk_d),
        .reset        (reset),
        .switch_val   (sw_readData[15:0]), // use value read from switches
        .led_writeData(led_writeData),
        .led_writeEn  (led_writeEn),
        .sw_readEn    (),
        .counting     (),
        .currentState ()
    );

    // counter value for 7-seg is lower 16 bits of led_writeData
    assign counter_val = led_writeData[15:0];

    // leds module 
    leds led_inst (
        .clk        (clk),
        .rst        (reset),
        .writeData  (led_writeData),
        .writeEnable(led_writeEn),
        .readEnable (1'b0),
        .memAddress (30'd0),
        .readData   (),
        .leds       ()
    );

    // BCD converter 
    wire [3:0] digit_0, digit_1, digit_2, digit_3;

    bcd_converter bcd_inst (
        .value  (counter_val),
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
