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

// 流水级IF-ID之间的寄存器
module if_id (
  
  input clk, // 时钟
  input rst, // 复位

  input wire[`WordRange] if_pc, // IF级PC
  input wire[`WordRange] if_ins, // IF级指令

  output reg[`WordRange] id_pc, // ID级PC
  output reg[`WordRange] id_ins, // ID级指令

  input wire pause, // 流水线暂停信号

  //异常相关
  input wire flush
  
);

  always @(posedge clk) begin
    // 重置时向下级送0x0
    if (rst == `Enable) begin
      id_pc = `ZeroWord;
      id_ins = `ZeroWord;
    // 暂停时保持不变
    end else if (flush == `Enable) begin
      id_pc = `ZeroWord;
      id_ins = `ZeroWord;
    end else if (pause == `Enable) begin
      id_pc = id_pc;
      id_ins = id_ins;
    // 否则向下级直通传递
    end else begin
      id_pc = if_pc;
      id_ins = if_ins;
    end
  end

endmodule
