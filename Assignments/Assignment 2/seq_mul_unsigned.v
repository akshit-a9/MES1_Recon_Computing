// -----------------------------------------------------------------------------
// seq_mul_unsigned.v — Sequential shift-add multiplier (no IP)
// Verilog-2001
// -----------------------------------------------------------------------------
module seq_mul_unsigned #(
    parameter AW = 32,
    parameter BW = 32
)(
    input  wire                 clk,
    input  wire                 rst_n,
    input  wire                 start,
    input  wire [AW-1:0]        a,
    input  wire [BW-1:0]        b,
    output reg  [AW+BW-1:0]     p,
    output reg                  busy,
    output reg                  done
);
    localparam PW = AW + BW;

    reg [AW-1:0] a_reg;
    reg [BW-1:0] b_reg;
    reg [PW-1:0] acc;
    integer      cnt;

    always @(posedge clk) begin
        if (!rst_n) begin
            busy <= 1'b0;
            done <= 1'b0;
            acc  <= {PW{1'b0}};
            a_reg<= {AW{1'b0}};
            b_reg<= {BW{1'b0}};
            cnt  <= 0;
            p    <= {PW{1'b0}};
        end else begin
            done <= 1'b0;

            if (start && !busy) begin
                busy  <= 1'b1;
                a_reg <= a;
                b_reg <= b;
                acc   <= {PW{1'b0}};
                cnt   <= BW;
            end else if (busy) begin
                if (b_reg[0])
                    acc <= acc + {{BW{1'b0}}, a_reg};

                a_reg <= a_reg << 1;
                b_reg <= b_reg >> 1;

                if (cnt > 0)
                    cnt <= cnt - 1;

                if (cnt == 1) begin
                    busy <= 1'b0;
                    done <= 1'b1;
                    p    <= acc;
                end
            end
        end
    end
endmodule

