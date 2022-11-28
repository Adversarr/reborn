`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/11/23 16:20:29
// Design Name: 
// Module Name: ms1a
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


module ms1a(
  input wire board_clk,
  input wire board_rst,
  input wire[23:0] switches,
  input wire[4:0] buttons,
  input wire[3:0] keyboard_cols,
  input wire[3:0] keyboard_rows // TODO: Last Edit...
    );
    wire cpu_clk;
    cpu_clk(
      .clk_in1(board_clk), 
      .clk_out1(cpu_clk)
    );
    cpu cpu_inst(.clk(cpu_clk));
endmodule
