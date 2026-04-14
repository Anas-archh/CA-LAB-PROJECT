`timescale 1ns / 1ps

module top_rf_alu(
    input clk,
    input rst,
    input [31:0] rs1_val, // Value to initialize
    input [31:0] rs2_val, // Value to initialize
    input [1:0] disp_mux, // 00: rs1, 01: rs2, 10: ALU Result, 11: rd storage
    input regWrite_btn,   // Manual write enable from button
    input [15:0] sw,      // sw[4:0]=rs1_addr, sw[9:5]=rs2_addr, sw[12:10]=ALUop,
    output reg [15:0] led // Displays data based on disp_mux
    );

    // Internal Interconnects
    wire [31:0] readData1, readData2, aluResult;
    wire aluZero;
    
    // Control Signals
    reg [4:0] rs1_addr, rs2_addr, rd_addr;
    reg [3:0] aluControl;
    reg [31:0] writeData;
    reg internalWriteEnable;

    // FSM States
    parameter RESET_ST      = 2'b00;
    parameter INIT_rs1      = 2'b01;
    parameter INIT_rs2      = 2'b10;
    parameter OPERATIONAL   = 2'b11;

    reg [1:0] state, next_state;

    // 1. Register File Instance
    RegisterFile rf (
        .clk(clk),
        .rst(rst),
        .WriteEnable(internalWriteEnable), // Controlled by FSM and button
        .rs1(rs1_addr),
        .rs2(rs2_addr),
        .rd(rd_addr),
        .WriteData(writeData),
        .ReadData1(readData1),
        .ReadData2(readData2)
    );

    // 2. ALU Instance
    ALU32bit alu_inst (
        .A(readData1),
        .B(readData2),
        .ALUctl(aluControl),
        .ALUResult(aluResult),
        .Zero(aluZero)
    );

    // 3. FSM State Transition
    always @(posedge clk) begin
        if (rst) state <= RESET_ST;
        else state <= next_state;
    end

    // 4. FSM and Control Logic
    always @(*) begin
        // Defaults for Arithmetic Operations State
        next_state = state;
        internalWriteEnable = regWrite_btn; // Manual write by default
        rs1_addr = sw[4:0];       // Address from switches
        rs2_addr = sw[9:5];       // Address from switches
        rd_addr  = 5'd10;         // Default destination is x10
        aluControl = {1'b0,sw[12:10]};   // Op from switches
        writeData = aluResult;    // Write the ALU result back

        case (state)
            RESET_ST: next_state = INIT_rs1;

            INIT_rs1: begin
                rd_addr = sw[4:0];          // DYNAMIC: Uses switch value to pick target
                writeData = rs1_val;        // Value from input
                internalWriteEnable = 1'b1; // Auto-write
                next_state = INIT_rs2;
            end

            INIT_rs2: begin
                rd_addr = sw[9:5];          // DYNAMIC: Uses switch value to pick target
                writeData = rs2_val;        // Value from input
                internalWriteEnable = 1'b1; // Auto-write
                next_state = OPERATIONAL;
            end

            OPERATIONAL: begin
                internalWriteEnable = regWrite_btn; 
                rd_addr = 5'd10;            // Destination is Register 10
                
                // Hijack rs1 to look at rd_addr when mux is 11
                if (disp_mux == 2'b11) begin
                    rs1_addr = 5'd10; 
                end
                
                next_state = OPERATIONAL;  
            end
        endcase
    end

    // 5. Output Display Mux 
    always @(*) begin
        case(disp_mux)
            2'b00: led = readData1[15:0];   // register rs1 data
            2'b01: led = readData2[15:0];   // register rs2 data
            2'b10: led = aluResult[15:0];   // Show the current ALU result
            2'b11: led = readData1[15:0];   // Show the value stored at rd (hijacked rs1 port)
            default: led = 16'b0;
        endcase
    end

endmodule