`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/02 10:02:20
// Design Name: 
// Module Name: beep
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
`include "public.v"

module beep(
  input wire rst,
  input wire clk,
  input wire[`WordRange] addr,
  input wire en, // 使能
  input wire[3:0] byte_sel,
  input wire[`WordRange] data_in, // 声信号输入
  input wire we, //写使能
  
  //发送给仲裁器 所有外设都应有此输出
  output reg[`WordRange] data_out,
  
  //发送给外设的信号
  output reg signal_out // 声信号输出
  );
endmodule
