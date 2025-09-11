// ----------------------------
// DIV CLOCK
// ----------------------------
module clk_divider #(
    parameter WIDTH = 27,
    parameter [WIDTH-1:0] DIV_COUNT = 27'd49_999_999
)(
    input  wire clk,
    input  wire reset,
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
// SEQUENCE DETECTORS. FOR ME 69 WOULD MEAN 6+9 = 15 = 1+5 = 6 = 0110, AND ITS COMPLIMENT 1001
// ----------------------------
module seq_det_dual_moore(
    input  wire clk,
    input  wire reset,    
    input  wire x,        
    output wire z_0110,   
    output wire z_1001  
);

  localparam [3:0]
    S0        = 4'd0,   
    S_0       = 4'd1,   
    S_01      = 4'd2,   
    S_011     = 4'd3,   
    S_1       = 4'd4,  
    S_10      = 4'd5,   
    S_100     = 4'd6,  
    DET_0110  = 4'd7,   
    DET_1001  = 4'd8;  

  reg [3:0] state, next;

  always @(posedge clk or posedge reset) begin
    if (reset) state <= S0;
    else       state <= next;
  end

  always @* begin
    next = state;
    case (state)
      S0: begin
        if (x==0) next = S_0;
        else         next = S_1;
      end

      S_0: begin
        if (x==1) next = S_01;   
        else         next = S_0;   
      end
      S_01: begin
        if (x==1) next = S_011;  
        else         next = S_0;    
      end
      S_011: begin
        if (x==0) next = DET_0110; 
        else         next = S_1;     
      end


      S_1: begin
        if (x==0) next = S_10;  
        else         next = S_1;    
      end
      S_10: begin
        if (x==0) next = S_100;  
        else         next = S_1;    
      end
      S_100: begin
        if (x==1) next = DET_1001;
        else         next = S_0;      
      end


      DET_0110: begin
        if (x == 1'b0) next = S_0; else next = S_1;
       end
      DET_1001:   begin
        if (x == 1'b0) next = S_0; else next = S_1;
       end

      default:   next = S0;
    endcase
  end

  assign z_0110  = (state == DET_0110);
  assign z_1001  = (state == DET_1001);
endmodule

// ----------------------------
// SEQUENCE GENERATOR
// ----------------------------
module seq_generator #(
    parameter integer N = 16,
    parameter [N-1:0] PATTERN = 16'b1001_0110_1100_0011
)(
    input  wire clk,
    input  wire reset, 
    output reg  x
);
  reg [$clog2(N)-1:0] idx;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      idx <= {($clog2(N)){1'b0}};
      x   <= PATTERN[N-1];
    end else begin
      x   <= PATTERN[N-1-idx];                 
      idx <= (idx == N-1) ? {($clog2(N)){1'b0}}
                          : (idx + 1'b1);
    end
  end
endmodule

// ----------------------------
// INT_MAIN()
// ----------------------------
module top_seq_demo(
    input  wire CLK_IN,  
    input  wire RESET,    
    output wire LED0,     // pulse on "0110"
    output wire LED1,     // pulse on "1001"
    output wire BIT_OUT,  // sequence generator output
    output wire LED3      // shows divided clock
);
  wire slow_clk;
  wire x_bit;
  wire hit_0110, hit_1001;

  // Clock divider
  clk_divider #(
    .WIDTH(27),
    .DIV_COUNT(27'd49_999_999)
  ) u_div (
    .clk(CLK_IN),
    .reset(RESET),
    .div_clk(slow_clk)
  );

  // Sequence generator
  seq_generator #(
    .N(16),
    .PATTERN(16'b1001_0110_1100_0011)
  ) u_gen (
    .clk(slow_clk),
    .reset(RESET),
    .x(x_bit)
  );

  // Dual-sequence detector FSM
  seq_det_dual_moore u_det (
    .clk(slow_clk),
    .reset(RESET),
    .x(x_bit),
    .z_0110(hit_0110),
    .z_1001(hit_1001)
  );

  // Assign outputs
  assign LED0    = hit_0110;
  assign LED1    = hit_1001;
  assign BIT_OUT = x_bit;
  assign LED3    = slow_clk;  // new output to visualize divided clock
endmodule