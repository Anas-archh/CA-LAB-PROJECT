`timescale 1ns / 1ps

module top_lab7(
    input wire clk,               // 100MHz clock from FPGA
    input wire rst,               // Center button (BTNC)
    
    input wire [15:0] sw,         // 16 physical switches
    
    output wire [6:0] seg,        // 7-segment display segments (a-g)
    output wire [3:0] an          // 7-segment display anodes
    );

    // --- Internal Wires ---
    wire [31:0] switch_read_data; // Output from your switches module
    wire [15:0] rf_alu_result;    // Output from your top_rf_alu module
    wire clk_d;

    clk_div #(.div_value(0)) clk_div_inst (
        .clk (clk),
        .clk_d (clk_d)
    );

     
        // 1. Instantiate the Switches Module
        switches sw_inst (
            .clk(clk),
            .rst(rst),
            .btns(16'b0),              // Not used in this lab
            .writeData(32'b0),         // Not writing to switches
            .writeEnable(1'b0),        // Disable write
            .readEnable(1'b1),         // Always read the switches
            .memAddress(30'b0),
            .switches(sw),             // Connect to physical switches
            .readData(switch_read_data)
        );
    
        // 2. Instantiate the Datapath (Register File + ALU)
        // We use the top two switches for the display mux: disp_mux = sw[15:14]
        wire [1:0] display_mux_ctrl = sw[14:13];
    
        top_rf_alu datapath_inst (
            .clk(clk_d),
            .rst(rst),
            .rs1_val(switch_read_data[4:0]),
            .rs2_val(switch_read_data[9:5]),
            .disp_mux(display_mux_ctrl),
            .regWrite_btn(switch_read_data[15]),
            .sw(switch_read_data[15:0]), // Use synchronized switches from module above
            .led(rf_alu_result)
        );
    
        // seven segment display 
        seven_segment seg_inst (
            .clk    (clk),
            .reset  (rst),
            .digit_0(rf_alu_result[3:0]),
            .digit_1(rf_alu_result[7:4]),
            .digit_2(rf_alu_result[11:8]),
            .digit_3(rf_alu_result[15:12]),
        .seg    (seg),
        .an     (an)
    );

endmodule