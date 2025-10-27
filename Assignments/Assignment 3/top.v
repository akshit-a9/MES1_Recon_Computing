`timescale 1ns / 1ps

module top (
    input wire clk,           // 100 MHz clock from ZedBoard
    input wire enable_sw,     // DIP switch for enable
    output wire ref_clk_out,  // reference clk/2 output
    output wire wave_led      // optional: output visible on LED
);
    // Internal signals
    wire reset_vio;
    wire [3:0] m_vio, n_vio;
    wire wave_out;

    // Instantiate DUT
    square_wave_gen dut (
        .clk(clk),
        .reset(reset_vio),
        .enable(enable_sw),
        .m(m_vio),
        .n(n_vio),
        .wave_out(wave_out)
    );

    // Reference clock divider (clk/2 = 20 ns period)
    reg ref_clk = 0;
    always @(posedge clk) ref_clk <= ~ref_clk;
    assign ref_clk_out = ref_clk;

    // Optional LED output (just to see toggling)
    assign wave_led = wave_out;

    // VIO IP instance
    vio_0 vio_inst (
        .clk(clk),
        .probe_out0(m_vio),   // 4-bit m input
        .probe_out1(n_vio),   // 4-bit n input
        .probe_out2(reset_vio) // 1-bit reset
    );

    // ILA IP instance (for observation)
    ila_0 ila_inst (
        .clk(clk),
        .probe0(wave_out),
        .probe1(ref_clk),
        .probe2(m_vio),
        .probe3(n_vio),
        .probe4(enable_sw)
    );

endmodule
