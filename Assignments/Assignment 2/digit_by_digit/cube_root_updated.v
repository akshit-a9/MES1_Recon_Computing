// Integer cube root (digit-by-digit, base-2) for a 32-bit unsigned input.
// Produces the truncated integer cube root (no scaling, no fractional part).
module cube_root(
    input  wire        clk,
    input  wire        reset,
    input  wire [31:0] number_in,
    output reg  [31:0] number_out
);

    // Internal state
    reg  [35:0] N_pad;        // {2'b00, number_in, 2'b00} → 12 groups of 3 bits
    reg  [35:0] rem;          // running remainder
    reg  [11:0] y;            // cube root being built (up to 12 bits for 36-bit operand)
    reg  [5:0]  bitptr;       // starts at 33, steps down by 3 (33,30,...,0)
    reg         done;

    // Combinational helpers
    wire [2:0]  grp        = (N_pad >> bitptr) & 3'b111;       // next 3 MSB bits
    //wire [12:0] A          = {y,1'b0};                         // A = y << 1
    // trial = 3*A*(A+1) + 1 = 12*y^2 + 6*y + 1 (fits in < 28 bits; keep 32)
    wire [31:0] trial_w = (3 * y * (y + 1)) + 1;
    wire [35:0] rem_shift  = (rem << 3) | grp;
    wire        take_one   = (rem_shift >= trial_w);

    // Next-state for y and rem
    wire [11:0] y_next     = {y, take_one};
    wire [35:0] rem_next   = take_one ? (rem_shift - trial_w) : rem_shift;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Load operand and initialize state
            N_pad      <= {2'b00, number_in, 2'b00};
            rem        <= 36'd0;
            y          <= 12'd0;
            bitptr     <= 6'd33;        // 12 groups: 33,30,...,0
            done       <= 1'b0;
            number_out <= 32'd0;
        end else begin
            if (!done) begin
                // One digit (bit) of the cube root per cycle
                rem <= rem_next;
                y   <= y_next;

                if (bitptr == 6'd0) begin
                    done       <= 1'b1;
                    number_out <= {20'd0, y_next}; // final root (unscaled)
                end else begin
                    bitptr <= bitptr - 6'd3;
                end
            end
            // else: hold final result
        end
    end
endmodule
