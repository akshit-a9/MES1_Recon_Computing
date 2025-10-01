module cube_root(
    input  wire        clk,
    input  wire        reset,
    input  wire [31:0] number_in,
    output reg  [31:0] number_out
);

    // Internal state
    reg [35:0] N_pad;
    reg [35:0] rem;
    reg [11:0] root;
    reg [5:0]  bit_index;
    reg        done;

    reg [2:0]  curr_bits;
    reg [31:0] trial;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            N_pad      <= {2'b00, number_in, 2'b00};
            rem        <= 36'd0;
            root       <= 12'd0;
            bit_index  <= 6'd33;   // start at MSB group
            done       <= 1'b0;
            number_out <= 32'd0;
        end else if (!done) begin
            // bring down next 3 bits
            curr_bits = (N_pad >> bit_index) & 3'b111;
            rem       = (rem << 3) | curr_bits;

            // trial = 3*root*(root+1) + 1
            trial = ((3*root*root) + (3*root) + 1) << (bit_index/3);

            if (rem >= trial) begin
                rem  = rem - trial;
                root = (root << 1) | 1;
            end else begin
                root = (root << 1);
            end

            if (bit_index == 0) begin
                done       <= 1'b1;
                number_out <= root;   // final result
            end else begin
                bit_index <= bit_index - 3;
            end
        end
        // else: hold number_out
    end
endmodule
