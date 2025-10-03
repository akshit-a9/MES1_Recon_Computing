`timescale 1ns / 1ps

module cube_root(
    input clk,reset,
    input [31:0] number_in,
    output reg [31:0] number_out
    );
   
   reg [35:0] padded_number_in;
   reg [35:0] rem;
   reg [31:0] trial;
   reg [12:0] current_root;
   reg [11:0] cube_root;
   reg [5:0] bit_counter;
   reg [2:0] current_bits;
   reg [1:0] stage;
   reg new_bit;
   reg flag_complete;
   

always @(posedge clk or posedge reset)
begin
    if(reset == 1)
    begin
        number_out <= 0;
        padded_number_in <= {2'd0, number_in, 2'd0};
        cube_root <= 0;
        rem <= 0;
        trial <= 0;
        bit_counter <= 6'd35;
        current_bits <= 0;
        current_root <= 0;
        new_bit <= 0;
        flag_complete <= 0;
        stage <= 0;
    end
    else if (bit_counter != 0)
    begin
        if(stage == 0)
        begin
            current_bits = (padded_number_in >> (bit_counter - 2)) & 3'b111;
            rem = (rem << 3) | current_bits;
    
            current_root <= cube_root << 1;
            stage <= 1;
        end
        else if(stage == 1)
        begin
            trial <= (((current_root << 1) + current_root) * (current_root + 1)) + 1 ;
            stage <= 2'd2;
        end
        else
        begin    
            if(rem >= trial)
            begin
                new_bit = 1;
                rem = rem - trial;
            end
            else
                new_bit = 0;
            cube_root <= (cube_root << 1) | new_bit ;
            
            if(bit_counter <= 3)
            begin
                bit_counter <= 0;
                flag_complete <= 1;
            end
            else
                bit_counter <= bit_counter - 3;
                
            number_out <= cube_root;
            stage <= 0;
        end
    end
    else if(flag_complete == 1)
    begin
        flag_complete <= 0;
        number_out <= {number_out, 11'd0};
    end
end
endmodule
