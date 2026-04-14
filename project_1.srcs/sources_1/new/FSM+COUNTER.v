`timescale 1ns / 1ps

module fsm_counter(
    input  wire        clk,
    input  wire        reset,
    input  wire [15:0] switch_val,    // value readData from switches module
    output reg  [31:0] led_writeData, // connects to leds writeData
    output reg         led_writeEn,   // connects to leds writeEnable
    output reg         sw_readEn,     // connects to switches readEnable
    output reg         counting,       // high when in COUNTDOWN state
    output reg         currentState
);

    // state definitions
    localparam IDLE      = 2'b00;
    localparam COUNTDOWN = 2'b01;
    
    reg [1:0]  state;
    reg [15:0] counter;

    always @(posedge clk) begin
        if (reset) begin
            state          <= IDLE;
            counter        <= 16'd0;
            led_writeData  <= 32'd0;
            led_writeEn    <= 0;
            sw_readEn      <= 0;
            counting       <= 0;
            currentState   <= state;
        end else begin
            case (state)

                IDLE: begin
                    sw_readEn     <= 1;       // keep reading switches
                    led_writeEn   <= 1;
                    led_writeData <= 32'd0;   // LEDs off
                    counting      <= 0;
                    
                    //if readData from switches module sends a non zero value then transition to COUNTDOWN state
                    if (switch_val != 16'd0) begin
                        counter <= switch_val; // capture switch value
                        state   <= COUNTDOWN;
                        currentState <= COUNTDOWN; //for debugging in simulation
                    end
                end

                COUNTDOWN: begin
                    sw_readEn     <= 0;        // ignore switches
                    counting      <= 1;
                    led_writeEn   <= 1;
                    led_writeData <= {16'd0, counter}; // this is going in writeData of led module.

                    if (counter == 16'd0) begin
                        state         <= IDLE;
                        currentState  <= IDLE; //for debugging
                        led_writeData <= 32'd0;
                        counting      <= 0;
                    end else begin
                        counter <= counter - 1;
                    end
                end

                default: state <= IDLE;

            endcase
        end
    end

endmodule