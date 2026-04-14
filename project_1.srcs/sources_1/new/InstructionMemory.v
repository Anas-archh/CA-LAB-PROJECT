`timescale 1ns / 1ps

module InstructionMemory (
    input  wire [31:0] readAddress, // Connected to the Program Counter (PC)
    output reg  [31:0] instruction  // The 32-bit instruction sent to your datapath
);

    // Create a ROM array of 256 words (each 32 bits wide)
    reg [31:0] rom [0:255];

    initial begin
        // This command loads the machine_code.mem file you added earlier!
        $readmemh("machine_code.mem", rom);
    end

    // RISC-V addresses are byte-addressed (increments of 4).
    // By taking readAddress[9:2], we safely convert the byte address to a word index.
    always @(*) begin
        instruction = rom[readAddress[9:2]];
    end

endmodule