module cube_root_tb;

  reg clk, reset;
  reg [31:0] number_in;
  wire [31:0] number_out;

  cube_root uut (.clk(clk), .reset(reset), .number_in(number_in), .number_out(number_out));

  always #5 clk = ~clk; // 100MHz clock

  initial begin
    clk = 0;
    reset = 1; number_in = 32'd0; #20;
    reset = 0;

    // Test 8
    number_in = 32'd8; reset = 1; #10; reset = 0;
    repeat(20) @(posedge clk);
    $display("8 -> %d", number_out);

    // Test 27
    number_in = 32'd27; reset = 1; #10; reset = 0;
    repeat(20) @(posedge clk);
    $display("27 -> %d", number_out);

    // Test 64
    number_in = 32'd64; reset = 1; #10; reset = 0;
    repeat(20) @(posedge clk);
    $display("64 -> %d", number_out);

    // Test 125
    number_in = 32'd125; reset = 1; #10; reset = 0;
    repeat(20) @(posedge clk);
    $display("125 -> %d", number_out);

    // Test 1000
    number_in = 32'd1000; reset = 1; #10; reset = 0;
    repeat(40) @(posedge clk);
    $display("1000 -> %d", number_out);

    $finish;
  end
endmodule
