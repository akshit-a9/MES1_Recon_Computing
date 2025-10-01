`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.09.2025 20:16:07
// Design Name: 
// Module Name: cube_root
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module cube_root(
    input clk,reset,
    input [31:0] number_in,
    output reg [31:0] number_out
    );
   
   reg [35:0] padded_number_in;
   reg [11:0] cube_root_value;
   reg [12:0] A_val;
   reg [35:0] remainder;
   reg [31:0] trial_cost;
   reg [5:0] bit_counter;
   reg [2:0] current_bits;
   reg [1:0] pipeline_mode;
   reg new_bit;
   reg cube_root_complete;
   

always @(posedge clk or posedge reset)
begin
    if(reset == 1)
    begin
        number_out <= 0;
        padded_number_in <= {2'd0, number_in, 2'd0};
        cube_root_value <= 0;
        remainder <= 0;
        trial_cost <= 0;
        bit_counter <= 6'd35;
        current_bits <= 0;
        A_val <= 0;
        new_bit <= 0;
        cube_root_complete <= 0;
        pipeline_mode <= 0;
    end
    else if (bit_counter != 0)
    begin
        if(pipeline_mode == 0)
        begin
            current_bits = (padded_number_in >> (bit_counter - 2)) & 3'b111;
            remainder = (remainder << 3) | current_bits;
    
            A_val <= cube_root_value << 1;
            pipeline_mode <= 1;
        end
        else if(pipeline_mode == 1)
        begin
            trial_cost <= (((A_val << 1) + A_val) * (A_val + 1)) + 1 ;
            pipeline_mode <= 2'd2;
        end
        else
        begin    
            if(remainder >= trial_cost)
            begin
                new_bit = 1;
                remainder = remainder - trial_cost;
            end
            else
                new_bit = 0;
            cube_root_value <= (cube_root_value << 1) | new_bit ;
            
            if(bit_counter <= 3)
            begin
                bit_counter <= 0;
                cube_root_complete <= 1;
            end
            else
                bit_counter <= bit_counter - 3;
                
            number_out <= cube_root_value;
            pipeline_mode <= 0;
        end
    end
    else if(cube_root_complete == 1)
    begin
        cube_root_complete <= 0;
        number_out <= {number_out, 11'd0};
    end
end
endmodule
