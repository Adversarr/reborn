`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/02 10:02:20
// Design Name: 
// Module Name: leds
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
`include "defines.v"

module leds(
  input rst, // 重置，全部灭灯
  input clk, // 时钟
  
  //从总线来的数据 所有外设驱动都应有以下信号
  input wire[`WordRange] addr,
  input wire en, // 使能
  input wire[3:0] byte_sel,
  input wire[`WordRange] data_in, // 数据输入（来自cpu）
  input wire we, //写使能
  
  //发送给仲裁器 所有外设都应有此输出
  output reg[`WordRange] data_out,
  
  
  //发送给外设
  output reg[7:0] RLD, // 红灯
  output reg[7:0] YLD, // 黄灯
  output reg[7:0] GLD  // 绿灯
  );

  always @(posedge clk) begin  //写需要上升沿(minisys: ~cpuclk)
    if (rst == `Enable) begin
      RLD <= 8'h00;
      YLD <= 8'h00;
      GLD <= 8'h00;
    end else if(addr == 32'hfffffc60 && en == `Enable && we == `Enable) begin //地址正确 写使能有效 总使能有效
      RLD <= data_in[23:16];
      YLD <= data_in[15:8];
      GLD <= data_in[7:0];
    end
  end
  
  always @(*) begin
    if(rst == `Enable) begin
      data_out <= `ZeroWord;
    end else if (addr == 32'hfffffc60 && en == `Enable && we ==`Disable) begin
        data_out <= {8'h00, RLD, YLD, GLD};
    end else begin
        data_out <= `ZeroWord;
    end
   end

  
endmodule
