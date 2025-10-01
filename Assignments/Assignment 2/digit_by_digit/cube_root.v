module cube_root(
    input clk, reset,
    input [31:0] number_in,
    output reg [31:0] number_out
    );

    reg [31:0] trial;                 
    reg [35:0] rem;                   
    reg [11:0] cube_val;              
    reg [35:0] padded_input;          
    reg [12:0] aval;                 
    reg [5:0] bit_index;              
    reg [2:0] curr_bits;             
    reg [1:0] pipeline_stage;        
    reg new_bit;
    reg root_done;                  

always @(posedge clk or posedge reset)
begin
    if(reset == 1)
    begin
        number_out      <= 0;
        padded_input    <= {2'd0, number_in, 2'd0};
        cube_val        <= 0;
        rem             <= 0;
        trial           <= 0;
        bit_index       <= 6'd35;
        curr_bits       <= 0;
        aval            <= 0;
        new_bit         <= 0;
        root_done       <= 0;
        pipeline_stage  <= 0;
    end
    else if (bit_index != 0)
    begin
        if(pipeline_stage == 0)
        begin
            curr_bits = (padded_input >> (bit_index - 2)) & 3'b111;
            rem = (rem << 3) | curr_bits;

            aval <= cube_val << 1;
            pipeline_stage <= 1;
        end
        else if(pipeline_stage == 1)
        begin
            trial <= (((aval << 1) + aval) * (aval + 1)) + 1;
            pipeline_stage <= 2'd2;
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

            cube_val <= (cube_val << 1) | new_bit ;
            
            if(bit_index <= 3)
            begin
                bit_index <= 0;
                root_done <= 1;
            end
            else
                bit_index <= bit_index - 3;
                
            number_out <= cube_val;
            pipeline_stage <= 0;
        end
    end
    else if(root_done == 1)
    begin
        root_done <= 0;
        number_out <= {number_out, 11'd0};
    end
end
endmodule
