`timescale 1ns / 1ps
module MemorySystem_tb();

    // --- Inputs ---
    reg         clk;
    reg         rst;
    reg  [31:0] address;
    reg         readEnable;
    reg         writeEnable;
    reg  [31:0] writeData;
    reg  [15:0] switches;

    // --- Outputs ---
    wire [31:0] readData;
    wire [15:0] leds;

    // --- Instantiate the DUT ---
    addressDecoderTop dut (
        .clk        (clk),
        .rst        (rst),
        .address    (address),
        .readEnable (readEnable),
        .writeEnable(writeEnable),
        .writeData  (writeData),
        .switches   (switches),
        .readData   (readData),
        .leds       (leds)
    );

    // --- Clock Generation: 10ns period = 100MHz ---
    always #5 clk = ~clk;

    // --- Helper Task: Reset all signals ---
    task reset_all;
        begin
            rst         = 1;
            address     = 32'b0;
            readEnable  = 0;
            writeEnable = 0;
            writeData   = 32'b0;
            switches    = 16'b0;
            @(posedge clk); #1;
            rst = 0;
        end
    endtask

    // --- Helper Task: Write to an address ---
    task write_to;
        input [31:0] addr;
        input [31:0] data;
        begin
            address     = addr;
            writeData   = data;
            writeEnable = 1;
            readEnable  = 0;
            @(posedge clk); #1;
            writeEnable = 0;
        end
    endtask

    // --- Helper Task: Read from an address ---
    task read_from;
        input [31:0] addr;
        begin
            address     = addr;
            readEnable  = 1;
            writeEnable = 0;
            @(posedge clk); #1;
            readEnable  = 0;
        end
    endtask

    // --- Main Test ---
    initial begin
        clk = 0;
        $display("===========================================");
        $display("      Memory System Testbench Start        ");
        $display("===========================================");

        // -----------------------------------------------
        // TEST 1: Reset
        // -----------------------------------------------
        $display("\n--- TEST 1: Reset ---");
        reset_all;
        $display("Reset applied. LEDs = %b (expect 0)", leds);

        // -----------------------------------------------
        // TEST 2: Write and Read from Data Memory
        // address[9:8] = 00 ? Data Memory (address 0x000)
        // -----------------------------------------------
        $display("\n--- TEST 2: Data Memory Write & Read ---");

        // Write 0xDEADBEEF to address 0x000
        write_to(32'h000, 32'hDEADBEEF);
        $display("Wrote 0xDEADBEEF to address 0x000");

        // Write 0x12345678 to address 0x004
        write_to(32'h004, 32'h12345678);
        $display("Wrote 0x12345678 to address 0x004");

        // Read back from address 0x000
        read_from(32'h000);
        $display("Read from 0x000 = 0x%h (expect 0xDEADBEEF)", readData);
        if (readData == 32'hDEADBEEF)
            $display("PASS: Data Memory read correct");
        else
            $display("FAIL: Data Memory read incorrect");

        // Read back from address 0x004
        read_from(32'h004);
        $display("Read from 0x004 = 0x%h (expect 0x12345678)", readData);
        if (readData == 32'h12345678)
            $display("PASS: Data Memory read correct");
        else
            $display("FAIL: Data Memory read incorrect");

        // -----------------------------------------------
        // TEST 3: Write to LEDs
        // address[9:8] = 01 ? LEDs (address 0x200 = 512)
        // -----------------------------------------------
        $display("\n--- TEST 3: LED Write ---");

        // Write 0x0000ABCD to LED address
        write_to(32'h100, 32'h0000ABCD);
        $display("Wrote 0x0000ABCD to LED address 0x200");
        $display("LEDs = 0x%h (expect 0xABCD)", leds);
        if (leds == 16'hABCD)
            $display("PASS: LEDs correct");
        else
            $display("FAIL: LEDs incorrect");

        // Write 0x0000FFFF to LEDs (all on)
        write_to(32'h100, 32'h0000FFFF);
        $display("Wrote 0xFFFF to LEDs");
        $display("LEDs = 0x%h (expect 0xFFFF)", leds);
        if (leds == 16'hFFFF)
            $display("PASS: LEDs all on correct");
        else
            $display("FAIL: LEDs incorrect");

        // -----------------------------------------------
        // TEST 4: Read from Switches
        // address[9:8] = 10 ? Switches (address 0x300 = 768)
        // -----------------------------------------------
        $display("\n--- TEST 4: Switch Read ---");

        // Set physical switches to 0xBEEF
        switches = 16'hBEEF;
        read_from(32'h200);
        $display("Switches set to 0xBEEF");
        $display("readData = 0x%h (expect 0x0000BEEF)", readData);
        if (readData == 32'h0000BEEF)
            $display("PASS: Switch read correct");
        else
            $display("FAIL: Switch read incorrect");

        // Change switches to 0x1234
        switches = 16'h1234;
        read_from(32'h200);
        $display("Switches changed to 0x1234");
        $display("readData = 0x%h (expect 0x00001234)", readData);
        if (readData == 32'h00001234)
            $display("PASS: Switch read correct");
        else
            $display("FAIL: Switch read incorrect");

        // -----------------------------------------------
        // TEST 5: Decoder Isolation
        // Writing to LED address should NOT affect Data Memory
        // -----------------------------------------------
        $display("\n--- TEST 5: Decoder Isolation ---");

        // First write a known value to data memory
        write_to(32'h008, 32'hCAFEBABE);
        $display("Wrote 0xCAFEBABE to DataMem address 0x008");

        // Now write something to LED address
        write_to(32'h100, 32'h0000AAAA);
        $display("Wrote 0xAAAA to LED address");

        // Data memory at 0x008 should be unchanged
        read_from(32'h008);
        $display("DataMem[0x008] = 0x%h (expect 0xCAFEBABE)", readData);
        if (readData == 32'hCAFEBABE)
            $display("PASS: DataMem unaffected by LED write");
        else
            $display("FAIL: DataMem was incorrectly affected");

        // -----------------------------------------------
        // TEST 6: Reading LED address should return 0
        // LEDs are write-only, readData should be 0
        // -----------------------------------------------
        $display("\n--- TEST 6: LED address read returns 0 ---");
        read_from(32'h100);
        $display("readData from LED address = 0x%h (expect 0x00000000)", readData);
        if (readData == 32'h00000000)
            $display("PASS: LED read correctly returns 0");
        else
            $display("FAIL: LED read returned unexpected value");

        // -----------------------------------------------
        // TEST 7: Reset clears LEDs
        // -----------------------------------------------
        $display("\n--- TEST 7: Reset clears LEDs ---");
        write_to(32'h100, 32'h0000FFFF); // turn all LEDs on
        $display("LEDs before reset = 0x%h", leds);
        rst = 1;
        @(posedge clk); #1;
        rst = 0;
        $display("LEDs after reset  = 0x%h (expect 0x0000)", leds);
        if (leds == 16'h0000)
            $display("PASS: Reset cleared LEDs");
        else
            $display("FAIL: Reset did not clear LEDs");

        // -----------------------------------------------
        $display("\n===========================================");
        $display("         Testbench Complete                ");
        $display("===========================================");
        $finish;
    end

endmodule