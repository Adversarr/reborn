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
  reg [23:0] switches;
  minisys1a spoc(
    .clk(clk),
    .rst(rst),
    .switches_in(switches)
  );
  
  initial begin
    clk = 0;
    rst = 1;
    switches = 24'h00_00F0;
    
    #500 rst = 0;
  end
  
  always #1 clk = ~clk;
endmodule
