module cube_root (
    input  wire        clk,
    input  wire        reset,
    input  wire [31:0] number_in,
    output reg  [11:0] root,        // 12 bits are enough for 32-bit input
    output reg         done
);

    reg [35:0] N_pad;
    reg [35:0] rem;
    reg [5:0]  bit_index;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            N_pad     <= {2'b00, number_in, 2'b00};
            rem       <= 0;
            root      <= 0;
            bit_index <= 6'd33;   // start at MSB group
            done      <= 0;
        end else if (!done) begin
            // bring down next 3 bits
            rem <= (rem << 3) | ((N_pad >> bit_index) & 3'b111);

            // compute trial = 3*root*(root+1) + 1
            // root is current partial result
            if (( (3*root*(root+1)) + 1 ) <= ((rem << 3) | ((N_pad >> bit_index) & 3'b111))) begin
                rem  <= ( (rem << 3) | ((N_pad >> bit_index) & 3'b111) ) - (3*root*(root+1) + 1);
                root <= (root << 1) | 1;
            end else begin
                root <= (root << 1);
            end

            if (bit_index == 0)
                done <= 1;
            else
                bit_index <= bit_index - 3;
        end
    end
endmodule
