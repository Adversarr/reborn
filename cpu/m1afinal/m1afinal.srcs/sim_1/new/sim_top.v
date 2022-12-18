`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/18 08:50:26
// Design Name: 
// Module Name: sim_top
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


module sim_top(

    );
  reg clk;
  reg rst;
  
  openmips_min_sopc spoc(
    .clk(clk),
    .rst(rst)
  );
  
  initial begin
    clk = 0;
    rst = 1;
    
    #100 rst = 0;
  end
  
  always #5 clk = ~clk;
endmodule
