`timescale 1ns / 1ps

module tb_square_wave_gen;

    reg clk, reset, enable;
    reg [3:0] m, n;
    wire wave_out;

    // Instantiate DUT
    square_wave_gen dut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .m(m),
        .n(n),
        .wave_out(wave_out)
    );

    // Clock generation (100 MHz → 10 ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Stimulus
    initial begin
        // Initialize signals
        reset  = 1;
        enable = 0;
        m = 0;
        n = 0;
        #20;

        // Release reset
        reset = 0;
        enable = 1;

        // Test 1: 3 µs ON, 2 µs OFF
        m = 4'd3;
        n = 4'd2;
        #1000; // observe

        // Test 2: 5 µs ON, 5 µs OFF
        m = 4'd5;
        n = 4'd5;
        #1500; // observe

        // Test 3: 7 µs ON, 2 µs OFF
        m = 4'd7;
        n = 4'd2;
        #1500;

        // Test 4: Disable generator
        enable = 0;
        #200;

        // Re-enable and change timing
        enable = 1;
        m = 4'd2;
        n = 4'd8;
        #1500;

        $finish;
    end

    // Monitor output
    initial begin
        $monitor("Time=%0t | m=%0d | n=%0d | wave_out=%b",
                  $time, m, n, wave_out);
    end

endmodule
