module AddressDecoder(
    input  [31:0] address,
    input         writeEnable,
    input         readEnable,
    output        DataMemWrite,    
    output        DataMemRead,     
    output        LEDWrite,        
    output        SwitchReadEnable 
);
    wire DataMemSelect = (address[9:8] == 2'b00);
    wire LEDSelect     = (address[9:8] == 2'b01);
    wire SwitchSelect  = (address[9:8] == 2'b10);

    assign DataMemWrite     = DataMemSelect & writeEnable;
    assign DataMemRead      = DataMemSelect & readEnable;
    assign LEDWrite         = LEDSelect     & writeEnable;
    assign SwitchReadEnable = SwitchSelect  & readEnable;
endmodule