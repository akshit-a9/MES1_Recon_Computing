`timescale 1ns/1ps

module tb_cube_root;

    reg clk, reset;
    reg [31:0] number_in;
    wire [31:0] number_out;

    // Instantiate DUT
    cube_root dut (
        .clk(clk),
        .reset(reset),
        .number_in(number_in),
        .number_out(number_out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock (10ns period)
    end

    // Task to apply input and show result
    task apply_input;
        input [31:0] val;
        integer int_val;
        real out_real;
        begin
            number_in = val;
            reset = 1; #10;  // assert reset
            reset = 0; #10;  // deassert reset
            #200;            // wait enough cycles for DUT to compute

            int_val = number_out;         // plain integer result
            out_real = int_val * 1.0;     // convert to real for printing

            $display("Input = %0d, Cube Root (hex) = 0x%08h, Cube Root (int) = %0d, Cube Root (real) = %f",
                     val >> 16, number_out, int_val, out_real);
        end
    endtask

    initial begin
        // Initialize
        reset = 0;
        number_in = 0;

        // Apply test values (integer shifted into 16.16 fixed-point)
        #20;
        apply_input(32'h0008_0000);  // 8.0  -> expected cube root ? 2
        apply_input(32'h001B_0000);  // 27.0 -> expected cube root ? 3
        apply_input(32'h0040_0000);  // 64.0 -> expected cube root ? 4
        apply_input(32'h007D_0000);  // 125.0 -> expected cube root ? 5
        apply_input(32'h03E8_0000);  // 1000.0 -> expected cube root ? 10

        #100;
        $finish;
    end

endmodule
