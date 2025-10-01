module top(
    input clk50  
    );

    wire reset;
    wire [31:0] number_in;
    wire [31:0] number_out;

    cube_root uut (
        .clk(clk50),
        .reset(reset),
        .number_in(number_in),
        .number_out(number_out)
    );

    // VIO instance (generated from IP catalog)
    vio_0 vio_inst (
        .clk(clk50),
        .probe_out0(reset),       // 1-bit control for reset
        .probe_out1(number_in),   // 32-bit input value
        .probe_in0(number_out)    // 32-bit cube root output
    );

endmodule
