// -----------------------------------------------------------------------------
// cuberoot_q16_16.v — Unsigned Q16.16 cube root (digit-by-digit restoring)
// - Input : 32-bit unsigned fixed-point (Q16.16)
// - Output: 32-bit unsigned fixed-point (Q16.16)
// - 32 root-bit iterations; internal multi-cycle per bit due to sequential mul
// - Verilog-2001 only (no SV). No IP cores.
// -----------------------------------------------------------------------------
module cuberoot_q16_16 (
    input  wire        clk,
    input  wire        rst_n,       // active-low synchronous reset
    input  wire        start,       // one-cycle pulse
    input  wire [31:0] x_q16_16,    // unsigned Q16.16
    output reg  [31:0] y_q16_16,    // unsigned Q16.16 (result)
    output reg         busy,
    output reg         valid
);

    // State encoding
    localparam S_IDLE   = 3'd0;
    localparam S_LOAD   = 3'd1;
    localparam S_BRING  = 3'd2;
    localparam S_TRIAL  = 3'd3;
    localparam S_CMPUPD = 3'd4;
    localparam S_DONE   = 3'd5;

    reg [2:0] state, nxt_state;

    // 96-bit radicand shift register: {x, 64'b0}; we bring 3 MSBs per iter
    reg [95:0] rad_ext;
    reg [6:0]  grp_idx;  // 31..0 (32 groups of 3 bits)

    // Remainder and partial root
    reg [63:0] R;        // remainder (wide for headroom)
    reg [31:0] Y;        // partial root (build 32 bits)

    // Next 3 bits are always at the top [95:93]
    wire [2:0] next3 = rad_ext[95:93];

    // Trial computation: T = 12*Y^2 + 6*Y + 1
    reg         trial_req;
    reg         trial_rdy;
    reg  [31:0] Y_latched;
    wire [63:0] y2;          // Y*Y
    reg  [63:0] T;

    // Sequential multiplier (unsigned)
    reg  mul_start;
    wire mul_busy;
    wire mul_done;

    seq_mul_unsigned #(.AW(32), .BW(32)) u_mul (
        .clk   (clk),
        .rst_n (rst_n),
        .start (mul_start),
        .a     (Y_latched),
        .b     (Y_latched),
        .p     (y2),
        .busy  (mul_busy),
        .done  (mul_done)
    );

    // FSM next-state
    always @(*) begin
        nxt_state = state;
        case (state)
            S_IDLE:   if (start)     nxt_state = S_LOAD;
            S_LOAD:                 nxt_state = S_BRING;
            S_BRING:                nxt_state = S_TRIAL;
            S_TRIAL:  if (trial_rdy) nxt_state = S_CMPUPD;
            S_CMPUPD: if (grp_idx==0) nxt_state = S_DONE; else nxt_state = S_BRING;
            S_DONE:                 nxt_state = S_IDLE;
            default:                nxt_state = S_IDLE;
        endcase
    end

    // Main FSM / datapath
    reg s_trial_armed;
    always @(posedge clk) begin
        if (!rst_n) begin
            state      <= S_IDLE;
            busy       <= 1'b0;
            valid      <= 1'b0;
            y_q16_16   <= 32'd0;
            rad_ext    <= 96'd0;
            grp_idx    <= 7'd0;
            R          <= 64'd0;
            Y          <= 32'd0;
            trial_req  <= 1'b0;
            trial_rdy  <= 1'b0;
            Y_latched  <= 32'd0;
            T          <= 64'd0;
            mul_start  <= 1'b0;
            s_trial_armed <= 1'b0;
        end else begin
            state     <= nxt_state;
            mul_start <= 1'b0;      // default
            trial_rdy <= 1'b0;      // default

            case (nxt_state)
                S_IDLE: begin
                    busy   <= 1'b0;
                    valid  <= 1'b0;
                end

                S_LOAD: begin
                    busy     <= 1'b1;
                    valid    <= 1'b0;
                    rad_ext  <= {x_q16_16, 64'd0}; // MSBs consumed first
                    grp_idx  <= 7'd31;             // 32 groups total
                    R        <= 64'd0;
                    Y        <= 32'd0;
                    trial_req<= 1'b0;
                    s_trial_armed <= 1'b0;
                end

                S_BRING: begin
                    // R <- (R << 3) | next3
                    R       <= {R[60:0], 3'b000} | {61'd0, next3};
                    // shift radicand left by 3 to expose next group
                    rad_ext <= {rad_ext[92:0], 3'b000};
                end

                S_TRIAL: begin
                    // Start Y^2 once per iteration
                    if (!s_trial_armed) begin
                        Y_latched     <= Y;
                        mul_start     <= 1'b1;   // one-cycle start
                        s_trial_armed <= 1'b1;
                    end else if (mul_done) begin
                        // 12*y2 = (y2<<3) + (y2<<2)
                        //  6*Y  = (Y<<2)  + (Y<<1)
                        T         <= ((y2 << 3) + (y2 << 2))
                                   + ({32'd0, (Y_latched << 2)} + {32'd0, (Y_latched << 1)})
                                   + 64'd1;
                        trial_rdy <= 1'b1;
                        s_trial_armed <= 1'b0;
                    end
                end

                S_CMPUPD: begin
                    if (R >= T) begin
                        R <= R - T;
                        Y <= {Y[30:0], 1'b1};
                    end else begin
                        Y <= {Y[30:0], 1'b0};
                    end
                    if (grp_idx != 0)
                        grp_idx <= grp_idx - 1;
                end

                S_DONE: begin
                    busy      <= 1'b0;
                    valid     <= 1'b1;
                    y_q16_16  <= Y; // Y already aligned for Q16.16
                end

                default: ;
            endcase
        end
    end

endmodule

