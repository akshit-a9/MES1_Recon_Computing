`timescale 1ns/1ps
module tb_cuberoot_q16_16;

    reg         clk, rst_n, start;
    reg  [31:0] x_q16_16;
    wire [31:0] y_q16_16;
    wire        busy, valid;

    cuberoot_q16_16 dut (
        .clk(clk), .rst_n(rst_n),
        .start(start),
        .x_q16_16(x_q16_16),
        .y_q16_16(y_q16_16),
        .busy(busy), .valid(valid)
    );

    // 100 MHz clock
    initial begin clk = 0; forever #5 clk = ~clk; end

    task kick;
    begin
        @(posedge clk);
        start <= 1'b1;
        @(posedge clk);
        start <= 1'b0;
        wait(valid == 1'b1);
        $display("X=0x%08h -> Y=0x%08h (Q16.16)", x_q16_16, y_q16_16);
        @(posedge clk); // one extra cycle
    end
    endtask

    // Q16.16 constants (integer * 65536)
    localparam [31:0] Q_1_0 = 32'd65536;        // 1.0
    localparam [31:0] Q_8_0 = 32'd524288;       // 8.0
    localparam [31:0] Q_27_0= 32'd1769472;      // 27.0
    localparam [31:0] Q_0_5 = 32'd32768;        // 0.5
    localparam [31:0] Q_2_0 = 32'd131072;       // 2.0

    initial begin
        rst_n = 0; start = 0; x_q16_16 = 0;
        repeat(5) @(posedge clk);
        rst_n = 1;

        x_q16_16 = Q_1_0;  kick();   // expect ~1.0 -> 0x00010000
        x_q16_16 = Q_8_0;  kick();   // expect ~2.0 -> 0x00020000
        x_q16_16 = Q_27_0; kick();   // expect ~3.0 -> 0x00030000
        x_q16_16 = Q_0_5;  kick();   // expect ~0.7937 -> ~0x0000CB92
        x_q16_16 = Q_2_0;  kick();   // expect ~1.2599 -> ~0x000144AE

        $finish;
    end
endmodule

