`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/02 10:02:20
// Design Name: 
// Module Name: switches
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


module switches(
  input rst, // 重置
  input clk, // 时钟

  //从总线来的数据 所有外设驱动都应有以下信号
  input wire[`WordRange] addr,
  input wire en, // 使能
  input wire[3:0] byte_sel,
  input wire[`WordRange] data_in, // 数据输入（来自cpu）
  input wire we, //写使能


  //发送给仲裁器 所有外设都应有此输出
  output reg[`WordRange] data_out,

  input[23:0] switch_in // 24位拨码  来自外设
  );
  
  reg[23:0] switch_reg; //内部寄存器
  
  always @(posedge clk) begin  //从外设读并写入寄存器 此寄存器不允许从cpu写入
    if (rst) begin
      switch_reg <= 24'd0;
    end else begin
      switch_reg <= switch_in;
    end
  end
  
  always @(*) begin
    if(rst == `Enable) begin
      data_out <= `ZeroWord;
    end else if(addr == 32'hfffffc70 && en == `Enable && we == `Disable)begin
      data_out <= switch_reg;
    end else begin
      data_out <= `ZeroWord;
    end
  end
endmodule
