//`timescale 1ns / 1ps
//module switches(
//    input clk, rst,
//    input [15:0] btns,
//    input [31:0] writeData, //  not to be written
//    input writeEnable, // not to be used
//    input readEnable,
//    input [29:0] memAddress,
//    input [15:0] switches,
    
//    output reg  [31:0] readData
//    );
    
//    reg [7:0] switchData [3:0]; 
//    always @(*) begin
//        switchData[0] = switches[7:0];
//        switchData[1] = switches[15:8];
//        switchData[2] = 8'b0;
//        switchData[3] = 8'b0;
        
//    end
    
//    always @(*) begin
////        un comment this cuz when designing processor:
////        if(readEnable) readData <= {switchData[memAddress+3],
////			switchData[memAddress+2],
////			switchData[memAddress+1],
////			switchData[memAddress]};

////        we currently need this:
//        if(readEnable) begin readData <= {switchData[3],
//			switchData[2],
//			switchData[1],
//			switchData[0]};
//		end else begin
//		    readData <= 32'b0;
//		end
//	end 
//endmodule


`timescale 1ns / 1ps
module switches(
    input         clk,              // kept for port compatibility, unused
    input         rst,              // kept for port compatibility, unused
    input  [15:0] btns,             // kept for port compatibility, unused
    input  [31:0] writeData,        // kept for port compatibility, unused
    input         writeEnable,      // kept for port compatibility, unused
    input         readEnable,
    input  [29:0] memAddress,       // kept for port compatibility, unused
    input  [15:0] switches,
    output reg [31:0] readData
);

    // Switches are read-only input device.
    // Combinational read - data available same cycle, no clock needed.
    // All write-related ports are unused.
    always @(*) begin
        if (readEnable)
            readData = {16'b0, switches};  // blocking = for combinational
        else
            readData = 32'b0;
    end

endmodule