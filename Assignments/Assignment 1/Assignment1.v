// ============================================================================
// Minimal Lab: Divided clock + Moore sequence detectors (0110, 1001) + generator
// Reset: active-high
// ============================================================================

// ----------------------------
// (1) Clock Divider
// ----------------------------
module clk_divider #(
    parameter WIDTH = 27,
    // For ~1 Hz from 100 MHz: toggle every 50_000_000 cycles
    parameter [WIDTH-1:0] DIV_COUNT = 27'd49_999_999
)(
    input  wire clk,
    input  wire reset,    // active-high
    output reg  div_clk
);
  reg [WIDTH-1:0] cnt;

  always @(posedge clk) begin
    if (reset) begin
      cnt     <= {WIDTH{1'b0}};
      div_clk <= 1'b0;
    end else if (cnt == DIV_COUNT) begin
      cnt     <= {WIDTH{1'b0}};
      div_clk <= ~div_clk;
    end else begin
      cnt <= cnt + {{WIDTH-1{1'b0}},1'b1};
    end
  end
endmodule

// ----------------------------
// (2a) Moore Sequence Detector: 0110 (no overlap)
// Output z goes high for 1 clock when 0110 is seen
// ----------------------------
module seq_det_0110_moore(
    input  wire clk,
    input  wire reset,  // active-high
    input  wire x,
    output wire z
);
  // States
  localparam [2:0]
    S0 = 3'd0, // idle
    S1 = 3'd1, // seen 0
    S2 = 3'd2, // seen 01
    S3 = 3'd3, // seen 011
    S4 = 3'd4; // detected (0110)

  reg [2:0] state, next;

  // State register
  always @(posedge clk or posedge reset) begin
    if (reset) state <= S0;
    else       state <= next;
  end

  // Next-state logic (no overlap handling)
  always @* begin
    next = state;
    case (state)
      S0: begin
        if (x==1'b0) next = S1;
        else         next = S0;
      end
      S1: begin // have '0', want '1'
        if (x==1'b1) next = S2;
        else         next = S1; // still 0; stay (no overlap requirement keeps it simple)
      end
      S2: begin // have '01', want '1'
        if (x==1'b1) next = S3;
        else         next = S1; // got 0; could be start of new
      end
      S3: begin // have '011', want '0'
        if (x==1'b0) next = S4; // detect
        else         next = S0; // wrong bit; reset
      end
      S4: begin
        next = S0; // one-cycle detect pulse; no overlap
      end
      default: next = S0;
    endcase
  end

  // Moore output
  assign z = (state == S4);
endmodule

// ----------------------------
// (2b) Moore Sequence Detector: 1001 (no overlap)
// Output z goes high for 1 clock when 1001 is seen
// ----------------------------
module seq_det_1001_moore(
    input  wire clk,
    input  wire reset,  // active-high
    input  wire x,
    output wire z
);
  // States
  localparam [2:0]
    T0 = 3'd0, // idle
    T1 = 3'd1, // seen 1
    T2 = 3'd2, // seen 10
    T3 = 3'd3, // seen 100
    T4 = 3'd4; // detected (1001)

  reg [2:0] state, next;

  // State register
  always @(posedge clk or posedge reset) begin
    if (reset) state <= T0;
    else       state <= next;
  end

  // Next-state logic (no overlap handling)
  always @* begin
    next = state;
    case (state)
      T0: begin
        if (x==1'b1) next = T1;
        else         next = T0;
      end
      T1: begin // have '1', want '0'
        if (x==1'b0) next = T2;
        else         next = T1; // still 1; stay
      end
      T2: begin // have '10', want '0'
        if (x==1'b0) next = T3;
        else         next = T1; // got 1; maybe start again
      end
      T3: begin // have '100', want '1'
        if (x==1'b1) next = T4; // detect
        else         next = T0; // wrong bit; reset
      end
      T4: begin
        next = T0; // one-cycle detect; no overlap
      end
      default: next = T0;
    endcase
  end

  // Moore output
  assign z = (state == T4);
endmodule

// ----------------------------
// (3) Sequence Generator (simple pattern ROM)
// Repeats a fixed pattern that contains both 0110 and 1001.
// ----------------------------
module seq_generator #(
    parameter integer N = 16,
    parameter [N-1:0] PATTERN = 16'b1001_0110_1100_0011
)(
    input  wire clk,
    input  wire reset,  // active-high
    output reg  x
);
  reg [$clog2(N)-1:0] idx;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      idx <= {($clog2(N)){1'b0}};
      x   <= 1'b0;
    end else begin
      // Output MSB-first (wrap around)
      x   <= PATTERN[N-1-idx];
      idx <= (idx == N-1) ? {($clog2(N)){1'b0}} : (idx + 1'b1);
    end
  end
endmodule

// ----------------------------
// (Top) Hook everything together
// Adjust ports to your board (ZedBoard: 100 MHz clock, map LEDs in XDC)
// ----------------------------
module top_seq_demo(
    input  wire CLK_IN,   // e.g., 100 MHz
    input  wire RESET,    // active-high pushbutton
    output wire LED0,     // detect 0110 pulse
    output wire LED1,     // detect 1001 pulse
    output wire BIT_OUT   // observe generator serial bit
);
  wire slow_clk;
  wire x_bit;
  wire hit_0110, hit_1001;

  // 1) Divide the board clock
  clk_divider #(
    .WIDTH(27),
    .DIV_COUNT(27'd49_999_999) // ~1 Hz from 100 MHz; change as needed
  ) u_div (
    .clk(CLK_IN),
    .reset(RESET),
    .div_clk(slow_clk)
  );

  // 3) Generate a serial bitstream (contains 0110 and 1001)
  seq_generator #(
    .N(16),
    .PATTERN(16'b1001_0110_1100_0011)
  ) u_gen (
    .clk(slow_clk),
    .reset(RESET),
    .x(x_bit)
  );

  // 2a) Detect 0110 (Moore, no overlap)
  seq_det_0110_moore u_det_0110 (
    .clk(slow_clk),
    .reset(RESET),
    .x(x_bit),
    .z(hit_0110)
  );

  // 2b) Detect 1001 (Moore, no overlap)
  seq_det_1001_moore u_det_1001 (
    .clk(slow_clk),
    .reset(RESET),
    .x(x_bit),
    .z(hit_1001)
  );

  assign LED0   = hit_0110;
  assign LED1   = hit_1001;
  assign BIT_OUT= x_bit;
endmodule
