`timescale 1ns / 1ps

module square_wave_gen(
    input  wire        clk,
    input  wire        reset,
    input  wire        enable,
    input  wire [3:0]  m,      // ON time in microseconds
    input  wire [3:0]  n,      // OFF time in microseconds
    output reg         wave_out
);

    localparam integer CLOCK_FREQ = 100_000_000;   // 100 MHz
    localparam integer CYCLES_PER_US = 100;        // 1 µs = 100 clock cycles at 100 MHz

    reg [15:0] counter;
    reg [15:0] on_cycles;
    reg [15:0] off_cycles;
    reg        state; // 0 = OFF, 1 = ON

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            wave_out   <= 0;
            state      <= 0;
            counter    <= 0;
            on_cycles  <= 0;
            off_cycles <= 0;
        end
        else if (enable) begin
            on_cycles  <= m * CYCLES_PER_US;
            off_cycles <= n * CYCLES_PER_US;

            counter <= counter + 1;

            if (state == 1'b1) begin
                if (counter >= on_cycles) begin
                    counter  <= 0;
                    state    <= 1'b0;
                    wave_out <= 1'b0;
                end
            end
            else begin
                if (counter >= off_cycles) begin
                    counter  <= 0;
                    state    <= 1'b1;
                    wave_out <= 1'b1;
                end
            end
        end
        else begin
            wave_out <= 0;
            counter  <= 0;
        end
    end

endmodule
