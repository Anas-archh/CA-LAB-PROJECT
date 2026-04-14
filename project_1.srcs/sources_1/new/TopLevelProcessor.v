`timescale 1ns / 1ps

module TopLevelProcessor(
    input clk,       // 100MHz board clock
    input rst,       // Reset button
    output [6:0] seg, // 7-Segment cathodes
    output [3:0] an   // 7-Segment anodes
);

    // ==================================================================
    //                  CLOCK & DISPLAY LOGIC
    // ==================================================================

    wire slow_clk;
    wire [31:0] a0_value; // Pulls the pure final answer from the Register File
    reg [15:0] display_value;

    // 1. Generate the Slow Clock for the CPU (10Hz)
    // NOTE: Assuming top_timer has these exact ports. If different, adjust accordingly.
    top_timer clock_slower (
        .clk(clk),
        .rst(rst),
        .slow_clk(slow_clk)
    );

    // 2. Feed the latest a0 value to the display register
    always @(posedge clk) begin
        if (rst)
            display_value <= 16'b0;
        else
            display_value <= a0_value[15:0]; 
    end

    // 3. The 7-Segment Driver (Uses the fast 100MHz clock to prevent flicker)
    seven_segment_display drive_segments (
        .clk(clk),
        .reset(rst),
        .digit_0(display_value[3:0]),   // Rightmost digit
        .digit_1(display_value[7:4]),   
        .digit_2(display_value[11:8]),  
        .digit_3(display_value[15:12]), // Leftmost digit
        .seg(seg),
        .an(an)
    );

    // ==================================================================
    //                 RISC-V CPU DATAPATH INSTANTIATIONS
    // ==================================================================
    
    // --- DATAPATH WIRES ---
    wire [31:0] next_PC, PC, PC_plus_4, branch_target, jump_target;
    wire [31:0] instruction;
    wire [31:0] ReadData1, ReadData2, WriteData;
    wire [31:0] imm;
    wire [31:0] alu_in2, alu_result;
    wire [31:0] mem_read_data;
    
    // --- CONTROL WIRES ---
    wire Branch, BranchNE, Jump, IsJALR;
    wire MemRead, MemWrite, ALUSrc, RegWrite;
    wire [1:0] ALUOp;
    wire [1:0] ResultSrc;
    wire [3:0] ALUCtrl;
    wire Zero;
    wire PCSrc;
    wire JumpSrc;

    // Branch logic: 
    // - BEQ: Branch when Zero is 1 (equal)
    // - BNE: BranchNE when Zero is 0 (not equal)
    assign PCSrc = (Branch & Zero) | (BranchNE & ~Zero);
    
    // Jump logic: Any jump instruction (JAL or JALR)
    assign JumpSrc = Jump | IsJALR;

    // 1. Jump Target Calculation (for JAL)
    wire [31:0] jal_target;
    assign jal_target = PC + imm;
    
    // 2. JALR Target (PC = rs1 + imm, computed by ALU)
    wire [31:0] jalr_target;
    assign jalr_target = alu_result;
    
    // 3. Select between JAL and JALR targets
    wire [31:0] final_jump_target;
    assign final_jump_target = IsJALR ? jalr_target : jal_target;
    
    // 4. First MUX: Branch vs PC+4
    wire [31:0] pc_or_branch;
    mux2 branch_mux (
        .d0(PC_plus_4),
        .d1(branch_target),
        .sel(PCSrc),
        .y(pc_or_branch)
    );
    
    // 5. Second MUX: (PC+4 or Branch) vs Jump
    mux2 jump_mux (
        .d0(pc_or_branch),
        .d1(final_jump_target),
        .sel(JumpSrc),
        .y(next_PC)
    );

    // 6. Program Counter
    ProgramCounter pc_inst (
        .clk(slow_clk),   // SLOW CLOCK!
        .rst(rst),
        .next_PC(next_PC),
        .PC(PC)
    );

    // 7. PC Adder (PC + 4)
    pcAdder pc_adder_inst (
        .PC(PC),
        .PC_plus_4(PC_plus_4)
    );

    // 8. Instruction Memory
    InstructionMemory imem_inst (
        .readAddress(PC),
        .instruction(instruction)
    );

    // 9. Control Unit
    ControlUnit control_inst (
        .opcode(instruction[6:0]),
        .funct3(instruction[14:12]),
        .Branch(Branch),
        .BranchNE(BranchNE),
        .Jump(Jump),
        .IsJALR(IsJALR),
        .MemRead(MemRead),
        .ResultSrc(ResultSrc),
        .ALUOp(ALUOp),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite)
    );

    // 10. Register File
    RegisterFile reg_inst (
        .clk(slow_clk),   // SLOW CLOCK!
        .rst(rst),
        .rs1(instruction[19:15]),
        .rs2(instruction[24:20]),
        .rd(instruction[11:7]),
        .WriteData(WriteData),
        .WriteEnable(RegWrite),
        .ReadData1(ReadData1),
        .ReadData2(ReadData2),
        .a0_out(a0_value) // Extracts your final answer directly to the display!
    );

    // 11. Immediate Generator
    immGen imm_gen_inst (
        .inst(instruction),
        .imm(imm)
    );

    // 12. ALU Control
    ALUControl alu_ctrl_inst (
        .ALUOp(ALUOp),
        .funct3(instruction[14:12]),
        .funct7(instruction[31:25]),  // CORRECTED: Full funct7 field
        .Operation(ALUCtrl)
    );

    // 13. Multiplexer for ALU Input 2 (Register vs Immediate)
    mux2 alu_mux (
        .d0(ReadData2),
        .d1(imm),
        .sel(ALUSrc),
        .y(alu_in2)
    );

    // 14. ALU
    ALU alu_inst (
        .A(ReadData1),
        .B(alu_in2),
        .ALUControl(ALUCtrl),
        .Result(alu_result),
        .Zero(Zero)
    );

    // 15. Branch Adder (PC + Imm for branches)
    branchAdder branch_adder_inst (
        .PC(PC),
        .imm(imm),
        .branch_target(branch_target)
    );

    // 16. Data Memory
    DataMemory dmem_inst (
        .clk(slow_clk),   // SLOW CLOCK!
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .address(alu_result),
        .write_data(ReadData2),
        .read_data(mem_read_data)
    );

    // 17. Calculate PC+4 for JAL/JALR (return address)
    wire [31:0] pc_plus_4_for_link;
    assign pc_plus_4_for_link = PC_plus_4;

    // 18. Three-way MUX for Register Write Back
    // ResultSrc[1:0]:
    //   00 = ALU result
    //   01 = Memory data
    //   10 = PC+4 (for JAL/JALR)
    wire [31:0] result_alu_or_mem;
    mux2 alu_mem_mux (
        .d0(alu_result),
        .d1(mem_read_data),
        .sel(ResultSrc[0]),
        .y(result_alu_or_mem)
    );
    
    mux2 final_result_mux (
        .d0(result_alu_or_mem),
        .d1(pc_plus_4_for_link),
        .sel(ResultSrc[1]),
        .y(WriteData)
    );

endmodule