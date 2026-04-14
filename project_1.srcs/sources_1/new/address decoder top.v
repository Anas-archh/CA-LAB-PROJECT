`timescale 1ns / 1ps
module addressDecoderTop(
    input         clk,
    input         rst,
    input  [31:0] address,
    input         readEnable,
    input         writeEnable,
    input  [31:0] writeData,
    input  [15:0] switches,
    output [31:0] readData,
    output [15:0] leds
);
    wire DataMemWrite, DataMemRead, LEDWrite, SwitchReadEnable;

    AddressDecoder decoder (
        .address        (address),
        .writeEnable    (writeEnable),
        .readEnable     (readEnable),
        .DataMemWrite   (DataMemWrite),
        .DataMemRead    (DataMemRead),
        .LEDWrite       (LEDWrite),
        .SwitchReadEnable(SwitchReadEnable)
    );

    wire [31:0] dataMemReadData;
    wire [31:0] switchReadData;

    DataMemory datamem_inst (
        .clk       (clk),
        .MemWrite  (DataMemWrite),   // write only when decoder says so
        .address   (address),
        .writeData (writeData),
        .readData  (dataMemReadData)
    );

    leds leds_inst (
        .clk        (clk),
        .rst        (rst),
        .writeData  (writeData),
        .writeEnable(LEDWrite),      // write only when decoder says so
        .readEnable (1'b0),
        .memAddress (30'b0),
        .readData   (),
        .leds       (leds)
    );

    switches sw_inst (
        .clk        (clk),
        .rst        (rst),
        .btns       (16'b0),
        .writeData  (32'b0),
        .writeEnable(1'b0),
        .readEnable (SwitchReadEnable), // read only when decoder says so
        .memAddress (30'b0),
        .switches   (switches),
        .readData   (switchReadData)
    );

    // DataMemRead gates whether DataMemory output is valid
    assign readData = DataMemRead  ? dataMemReadData :
                      SwitchReadEnable ? switchReadData  :
                      32'b0;

endmodule