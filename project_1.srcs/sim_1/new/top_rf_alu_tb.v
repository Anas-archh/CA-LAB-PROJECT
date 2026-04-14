`timescale 1ns / 1ps

module top_rf_alu_tb;

    // Testbench signals
    reg clk;
    reg rst;
    reg [31:0] rs1_val;
    reg [31:0] rs2_val;
    reg [1:0] disp_mux;
    reg regWrite_btn;
    reg [15:0] sw;
    wire [15:0] led;

    // Instantiate DUT
    top_rf_alu uut (
        .clk(clk),
        .rst(rst),
        .rs1_val(rs1_val),
        .rs2_val(rs2_val),
        .disp_mux(disp_mux),
        .regWrite_btn(regWrite_btn),
        .sw(sw),
        .led(led)
    );

    // Clock generation: 10 ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Stimulus
    initial begin
        // Initialize
        rst = 1;
        rs1_val = 32'h0000_00F0; // Example value for rs1
        rs2_val = 32'h0000_0F0F; // Example value for rs2
        disp_mux = 2'b00;
        regWrite_btn = 0;
        sw = 16'b0;

        // Reset pulse
        #12 rst = 0;

        // Set rs1_addr = 1, rs2_addr = 2
        sw[4:0]  = 5'd1;  // rs1 address
        sw[9:5]  = 5'd2;  // rs2 address

        // Wait for FSM to initialize rs1 and rs2
        #50;

        // --- Test ALU operations ---
        // Each ALUop is sw[12:10], aluControl = {1'b0, sw[12:10]}

        // AND (ALUctl = 0000)
        sw[12:10] = 3'b000; //expected: 0x00000000
        disp_mux = 2'b10; // show ALU result
        #20 $display("AND result = %h", led);

        // OR (ALUctl = 0001)
        sw[12:10] = 3'b001; //expected 0x00000FFF	
        #20 $display("OR result = %h", led);

        // XOR (ALUctl = 0010)
        sw[12:10] = 3'b010; //expected: 0x00000FFF
        #20 $display("XOR result = %h", led);

        // ADD (ALUctl = 0011)
        sw[12:10] = 3'b011; //expected: 0x00000FFF
        #20 $display("ADD result = %h", led);

        // SUB (ALUctl = 0100)
        sw[12:10] = 3'b100; //expected: 0xFFFFF1E1
        #20 $display("SUB result = %h", led);

        // Shift left (ALUctl = 0101)
        sw[12:10] = 3'b101; //expected: 0x00001E1E
        #20 $display("Shift Left result = %h", led);

        // Shift right (ALUctl = 0110)
        sw[12:10] = 3'b110; //expected: 0x00000787
        #20 $display("Shift Right result = %h", led);

        // --- Test Display Mux ---
        disp_mux = 2'b00; #10 $display("LED shows rs1 = %h", led);
        disp_mux = 2'b01; #10 $display("LED shows rs2 = %h", led);
        disp_mux = 2'b10; #10 $display("LED shows ALU result = %h", led);
        disp_mux = 2'b11; #10 $display("LED shows rd storage = %h", led);

        // Finish
        #50 $finish;
    end

endmodule
