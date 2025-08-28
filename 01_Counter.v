`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.08.2025 16:29:51
// Design Name: 
// Module Name: counter
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


module counter(
    input clock,
    input reset,
    input count_e,
    output reg[7:0] count
    );
    
   parameter COUNTER_WIDTH = 8;
     ///////////////////////
  
  reg div_clk;
   reg [26:0] delay_count;
      ////////////////////////////////
   always @(posedge clock)
  begin
  
  if(reset)
  begin
  delay_count<=27'd0;
  div_clk <= 1'b0;
  end
  else
  if(delay_count==27'd67108864)
  begin
  delay_count<=27'd0;
  div_clk <= ~div_clk;
  end
  else
  begin
  delay_count<=delay_count+1;
  end
  end
  ////////////////////////

   //reg [COUNTER_WIDTH-1:0] <reg_name> = {COUNTER_WIDTH{1'b0}};

   always @(posedge div_clk or posedge reset)
      if(reset)
         count <= {COUNTER_WIDTH{1'b0}};
      else if (count_e)
         count <= count + 1'b1;
         
endmodule
