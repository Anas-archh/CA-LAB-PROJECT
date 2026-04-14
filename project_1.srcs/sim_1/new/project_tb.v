`timescale 1ns / 1ps
module Project_tb();
    reg clk, rst;
    
    // Note: If you changed this port to a0_out in your top module earlier, 
    // change the name here to match!
    wire [31:0] final_alu_result; 

    // Instantiate your processor
    TopLevelProcessor cpu (
        .clk(clk),
        .rst(rst),
        .final_alu_result(final_alu_result)
    );

    // 100MHz Clock
    always #5 clk = ~clk;

    // --- NEW: CYCLE-BY-CYCLE CONSOLE OUTPUT ---
    // This block triggers every time the clock ticks up
    always @(posedge clk) begin
        if (!rst) begin // Only print after the reset is turned off
            // %0t = Time, %h = Hexadecimal, %0d = Decimal
            $display("Time: %5t | PC: %h | Inst: %h | s2(loop count): %0d | a0(fib result): %0d", 
                     $time, 
                     cpu.PC,                           // Peeks inside CPU at the Program Counter
                     cpu.instruction,                  // Peeks at the fetched instruction
                     cpu.regfile_inst.registers[18],   // s2 (Register 18) - The loop countdown
                     cpu.regfile_inst.registers[10]    // a0 (Register 10) - The final answer
            );
        end
    end

    // --- MAIN SIMULATION BLOCK ---
    initial begin
        clk = 0;
        rst = 1; // Hold reset
        
        // Print a clean header for your console table
        $display("========================================================================");
        $display(" SIMULATION TRACE STARTING...");
        $display("========================================================================");

        #20 rst = 0; // Release reset to start the processor
        
        // Let it run for enough time to compute the 8th Fibonacci number
        #1500; 
        
        $display("========================================================================");
        $display(" SIMULATION FINISHED.");
        $display("========================================================================");
        $finish;
    end
endmodule