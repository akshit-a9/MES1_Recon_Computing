module cube_root_top (
    input clk           // real FPGA clock
    //output [31:0] number_out_leds  // optional, for LEDs
);

   // Internal signals driven by VIO
   wire reset_vio;
   wire [31:0] number_in_vio;
   wire [31:0] number_out;

   cube_root dut (
       .clk(clk),
       .reset(reset_vio),        // driven by VIO
       .number_in(number_in_vio),// driven by VIO
       .number_out(number_out)
   );

   // Optional: drive LEDs with lower 8 bits
   //assign number_out_leds = number_out;

   // VIO instance
   vio_0 vio_inst (
       .clk(clk),
       .probe_in0(number_out),
       .probe_out0(number_in_vio),
       .probe_out1(reset_vio)
   );

endmodule
