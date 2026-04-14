`timescale 1ns/1ps
module top_lab8(
    input        clk,
    input        rst,
    input  [5:0] address,
    input        readEnable,
    input        writeEnable,
    input  [3:0] writeData,
    input  [3:0] switches,

    output [6:0] seg,
    output [3:0] an
);

    reg readEn;
    reg writeEn;
    wire [15:0] leds;
    wire [31:0] readData;

    // --- Safety: prevent both enables being high simultaneously ---
    always @(*) begin
        case ({readEnable, writeEnable})
            2'b11:   begin readEn = 1'b0; writeEn = 1'b0; end
            default: begin readEn = readEnable; writeEn = writeEnable; end
        endcase
    end

    // --- Address Decoder Top ---
    addressDecoderTop decoder_inst (
        .clk        (clk),
        .rst        (rst),
        .address    ({22'b0, address[5:4], 4'b0, address[3:0]}),
        .readEnable (readEn),
        .writeEnable(writeEn),
        .writeData  ({28'b0, writeData}),   // pad 4-bit to 32-bit
        .switches   ({12'b0, switches}),    // pad 4-bit to 16-bit
        .readData   (readData),
        .leds       (leds)
    );

    // --- Display Mux ---
    wire [15:0] display_val;
    wire [1:0] device = address[5:4];

    assign display_val =
        ({readEn,  device} == 3'b110) ? readData[15:0]  : // readEn=1, device=10 ? Switches
        ({readEn,  device} == 3'b100) ? readData[15:0]      : // readEn=1, device=00 ? DataMem read
        ({writeEn, device} == 3'b100) ? {12'b0, writeData}  : // writeEn=1, device=00 ? DataMem write
        ({writeEn, device} == 3'b101) ? leds                : // writeEn=1, device=01 ? LED write
        16'b0;
        
    // --- Seven Segment ---
    seven_segment seg_inst (
        .clk    (clk),
        .reset  (rst),
        .digit_0(display_val[3:0]),    // ones
        .digit_1(display_val[7:4]),    // tens
        .digit_2(display_val[11:8]),   // hundreds
        .digit_3(display_val[15:12]), // thousands
        .seg    (seg),
        .an     (an)
    );

endmodule