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
  input wire en, // ʹ��
  input wire[3:0] byte_sel,
  input wire[`WordRange] data_in, // ���ź�����
  input wire we, //дʹ��
  
  //���͸��ٲ��� �������趼Ӧ�д����
  output reg[`WordRange] data_out,
  
  //���͸�������ź�
  output reg signal_out // ���ź����
  );
endmodule
