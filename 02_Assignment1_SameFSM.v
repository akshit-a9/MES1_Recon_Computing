// ============================================================================
// Single-FSM Solution: divided clock + dual-sequence Moore detector (no overlap)
// Sequences: 0110 and 1001
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
// (2) Single Moore FSM detecting BOTH 0110 and 1001 (no overlap)
// Outputs are 1-cycle pulses (Moore) via dedicated detect states.
// ----------------------------
module seq_det_dual_moore(
    input  wire clk,
    input  wire reset,    // active-high
    input  wire x,        // serial input bit
    output wire z_0110,   // pulse when "0110" detected
    output wire z_1001    // pulse when "1001" detected
);
  // States encode progress for BOTH patterns:
  // For 0110: S_0 -> S_01 -> S_011 -> DET_0110
  // For 1001: S_1 -> S_10 -> S_100 -> DET_1001
  // Merge + share fallbacks so we keep useful prefixes while building.
  localparam [3:0]
    S0        = 4'd0,   // idle
    S_0       = 4'd1,   // seen 0
    S_01      = 4'd2,   // seen 01
    S_011     = 4'd3,   // seen 011
    S_1       = 4'd4,   // seen 1
    S_10      = 4'd5,   // seen 10
    S_100     = 4'd6,   // seen 100
    DET_0110  = 4'd7,   // detect 0110 (Moore pulse)
    DET_1001  = 4'd8;   // detect 1001 (Moore pulse)

  reg [3:0] state, next;

  // State register
  always @(posedge clk or posedge reset) begin
    if (reset) state <= S0;
    else       state <= next;
  end

  // Next-state logic (NO OVERLAP: both detect states immediately return to S0)
  always @* begin
    next = state;
    case (state)
      S0: begin
        if (x==1'b0) next = S_0;
        else         next = S_1;
      end

      // --- Path for 0110 ---
      S_0: begin
        if (x==1'b1) next = S_01;   // 0->1
        else         next = S_0;    // stay with prefix '0'
      end
      S_01: begin
        if (x==1'b1) next = S_011;  // 01->1
        else         next = S_0;    // 01->0 keeps '0' prefix
      end
      S_011: begin
        if (x==1'b0) next = DET_0110; // 011->0 detect
        else         next = S_1;      // 011->1 could start 1001
      end

      // --- Path for 1001 ---
      S_1: begin
        if (x==1'b0) next = S_10;   // 1->0
        else         next = S_1;    // stay with prefix '1'
      end
      S_10: begin
        if (x==1'b0) next = S_100;  // 10->0
        else         next = S_1;    // 10->1 keeps '1' prefix
      end
      S_100: begin
        if (x==1'b1) next = DET_1001; // 100->1 detect
        else         next = S_0;      // 100->0 keeps '0' prefix
      end

      // Detect states: one-cycle pulse then reset to idle (no overlap)
      DET_0110:  next = S0;
      DET_1001:  next = S0;

      default:   next = S0;
    endcase
  end

  // Moore outputs (1-cycle high on detect states)
  assign z_0110  = (state == DET_0110);
  assign z_1001  = (state == DET_1001);
endmodule

// ----------------------------
// (3) Sequence Generator (ROM pattern)
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
      x   <= PATTERN[N-1-idx];                  // MSB-first
      idx <= (idx == N-1) ? {($clog2(N)){1'b0}} // wrap
                          : (idx + 1'b1);
    end
  end
endmodule

// ----------------------------
// Top-level: hook divider, generator, and single FSM detector
// ----------------------------
module top_seq_demo(
    input  wire CLK_IN,   // e.g., 100 MHz
    input  wire RESET,    // active-high pushbutton/switch
    output wire LED0,     // pulse on "0110"
    output wire LED1,     // pulse on "1001"
    output wire BIT_OUT   // optional: routed to LED/PMOD for observation
);
  wire slow_clk;
  wire x_bit;
  wire hit_0110, hit_1001;

  // 1) Divide the clock
  clk_divider #(
    .WIDTH(27),
    .DIV_COUNT(27'd49_999_999) // ~1 Hz from 100 MHz; adjust for your board
  ) u_div (
    .clk(CLK_IN),
    .reset(RESET),
    .div_clk(slow_clk)
  );

  // 3) Generate a test bitstream (contains both sequences)
  seq_generator #(
    .N(16),
    .PATTERN(16'b1001_0110_1100_0011)
  ) u_gen (
    .clk(slow_clk),
    .reset(RESET),
    .x(x_bit)
  );

  // 2) Single Moore FSM with two outputs
  seq_det_dual_moore u_det (
    .clk(slow_clk),
    .reset(RESET),
    .x(x_bit),
    .z_0110(hit_0110),
    .z_1001(hit_1001)
  );

  assign LED0    = hit_0110;
  assign LED1    = hit_1001;
  assign BIT_OUT = x_bit;
endmodule

