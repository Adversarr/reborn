`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/02 11:31:54
// Design Name: 
// Module Name: hilo
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
// hilo.v
// 2020-11 @ https://github.com/seu-cs-class2/minisys-1a-cpu

`include "public.v"

// HI/LO�Ĵ���
module hilo (

  input rst,
  input clk,

  input wire we_in,
  input wire[`WordRange] hi_in,
  input wire[`WordRange] lo_in,

  output reg[`WordRange] hi_out,
  output reg[`WordRange] lo_out

);

  always @(posedge clk) begin
    if (rst == `Enable) begin
      hi_out = `ZeroWord;
      lo_out = `ZeroWord;
    end else if (we_in == `Enable) begin
      hi_out = hi_in;
      lo_out = lo_in;
    end
  end

endmodule
