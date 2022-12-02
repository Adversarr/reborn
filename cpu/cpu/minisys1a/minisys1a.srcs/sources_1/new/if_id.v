`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/02 11:25:33
// Design Name: 
// Module Name: if_id
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

// ��ˮ��IF-ID֮��ļĴ���
module if_id (
  
  input clk, // ʱ��
  input rst, // ��λ

  input wire[`WordRange] if_pc, // IF��PC
  input wire[`WordRange] if_ins, // IF��ָ��

  output reg[`WordRange] id_pc, // ID��PC
  output reg[`WordRange] id_ins, // ID��ָ��

  input wire pause, // ��ˮ����ͣ�ź�

  //�쳣���
  input wire flush
  
);

  always @(posedge clk) begin
    // ����ʱ���¼���0x0
    if (rst == `Enable) begin
      id_pc = `ZeroWord;
      id_ins = `ZeroWord;
    // ��ͣʱ���ֲ���
    end else if (flush == `Enable) begin
      id_pc = `ZeroWord;
      id_ins = `ZeroWord;
    end else if (pause == `Enable) begin
      id_pc = id_pc;
      id_ins = id_ins;
    // �������¼�ֱͨ����
    end else begin
      id_pc = if_pc;
      id_ins = if_ins;
    end
  end

endmodule
