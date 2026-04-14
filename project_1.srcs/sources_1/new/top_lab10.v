`timescale 1ns / 1ps

module top_lab10(
    input  wire        clk,   // 100MHz system clock
    input  wire        rst,   // Center button for reset
    input  wire [15:0] sw,    // Physical switches
    output wire [15:0] led,   // Physical LEDs
    output wire [6:0]  seg,   // 7-Segment display segments
    output wire [3:0]  an     // 7-Segment display anodes
);

    // ==========================================
    // 1. CLOCK DIVIDER (Slow down the processor)
    // ==========================================
    // We slow down the processor to 1Hz so you can visually see the countdown on the LEDs!
    wire clk_slow;
    clk_div #(.div_value(12499999)) clk_div_inst (
        .clk(clk), 
        .clk_d(clk_slow)
    );

    // ==========================================
    // 2. PROGRAM COUNTER (PC) LOGIC
    // ==========================================
    reg  [31:0] PC;
    wire [31:0] next_PC;

    always @(posedge clk_slow or posedge rst) begin
        if (rst) 
            PC <= 32'b0; // Reset sends program back to the beginning
        else 
            PC <= next_PC;
    end

    // ==========================================
    // 3. INSTRUCTION MEMORY (From Task 3)
    // ==========================================
    wire [31:0] instr;
    InstructionMemory imem (
        .readAddress(PC),
        .instruction(instr)
    );

    // ==========================================
    // 4. INSTRUCTION DECODING & IMMEDIATE GEN
    // ==========================================
    wire [6:0] opcode = instr[6:0];
    wire [4:0] rd     = instr[11:7];
    wire [2:0] funct3 = instr[14:12];
    wire [4:0] rs1    = instr[19:15];
    wire [4:0] rs2    = instr[24:20];
    wire       funct7_5 = instr[30];
    // For I-type instructions, bit 30 belongs to the immediate, not funct7. So force it to 0:
    wire funct7_5_safe = (opcode == 7'b0010011) ? 1'b0 : instr[30];
    
    reg [31:0] imm;
    always @(*) begin
        case(opcode)
            7'b0010011, 7'b0000011, 7'b1100111: // I-type (ADDI, LW, JALR)
                imm = {{20{instr[31]}}, instr[31:20]};
            7'b0100011:                         // S-type (SW)
                imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            7'b1100011:                         // B-type (BEQ)
                imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
            7'b1101111:                         // J-type (JAL)
                imm = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
            default: imm = 32'b0;
        endcase
    end

    // ==========================================
    // 5. CONTROL UNITS (From Lab 9)
    // ==========================================
    wire RegWrite_ctrl, ALUSrc, MemRead, MemWrite, MemtoReg, Branch;
    wire [1:0] ALUOp;
    wire [3:0] ALUControl_wire;
    
    // Flags for jumps
    wire is_jal  = (opcode == 7'b1101111);
    wire is_jalr = (opcode == 7'b1100111);

    MainControl mc (
        .opcode(opcode),
        .RegWrite(RegWrite_ctrl),
        .ALUSrc(ALUSrc),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .MemtoReg(MemtoReg),
        .Branch(Branch),
        .ALUOp(ALUOp)
    );

    // Patch to ensure JAL and JALR write to the register file
    wire RegWrite = RegWrite_ctrl | is_jal | is_jalr;

    ALUControl ac (
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7_5(funct7_5_safe),
        .ALUControl(ALUControl_wire)
    );

    // ==========================================
    // 6. DATAPATH: REGISTER FILE & ALU (Labs 6/7)
    // ==========================================
    wire [31:0] ReadData1, ReadData2, WriteData;
    RegisterFile rf (
        .clk(clk_slow), 
        .rst(rst),
        .WriteEnable(RegWrite),
        .rs1(rs1), 
        .rs2(rs2), 
        .rd(rd),
        .WriteData(WriteData),
        .ReadData1(ReadData1), 
        .ReadData2(ReadData2)
    );

    wire [31:0] ALU_B = ALUSrc ? imm : ReadData2;
    wire [31:0] ALUResult;
    wire Zero;
    ALU32bit alu (
        .A(ReadData1), 
        .B(ALU_B), 
        .ALUctl(ALUControl_wire),
        .ALUResult(ALUResult), 
        .Zero(Zero)
    );

    // ==========================================
    // 7. MEMORY MAPPED I/O (From Lab 8)
    // ==========================================
    wire [31:0] MemReadData;
    wire [15:0] leds_out;
    addressDecoderTop mem_io (
        .clk(clk_slow), 
        .rst(rst),
        .address(ALUResult),
        .readEnable(MemRead),
        .writeEnable(MemWrite),
        .writeData(ReadData2),
        .switches(sw),          // Connect to physical Basys3 switches
        .readData(MemReadData),
        .leds(leds_out)         // Connect to physical Basys3 LEDs
    );
    assign led = leds_out;

    // ==========================================
    // 8. WRITEBACK & NEXT PC CALCULATION
    // ==========================================
    // Writeback Multiplexer
    assign WriteData = (is_jal | is_jalr) ? (PC + 4) :
                       (MemtoReg)         ? MemReadData : 
                                            ALUResult;

    // Branch and Jump Multiplexers
    wire do_branch = Branch & Zero;
    assign next_PC = is_jalr               ? (ReadData1 + imm) :
                     (do_branch | is_jal)  ? (PC + imm) : 
                                             (PC + 4);

    // ==========================================
    // 9. DEBUGGING: Show PC on 7-Segment Display
    // ==========================================
    // This uses the fast clock so the display multiplexing doesn't flicker
    wire [3:0] d0, d1, d2, d3;
    bcd_converter bcd (
        .value(leds_out), 
        .digit_0(d0), 
        .digit_1(d1), 
        .digit_2(d2), 
        .digit_3(d3)
    );
    seven_segment seg_inst (
        .clk(clk), 
        .reset(rst), 
        .digit_0(d0), 
        .digit_1(d1), 
        .digit_2(d2), 
        .digit_3(d3), 
        .seg(seg), 
        .an(an)
    );

endmodule