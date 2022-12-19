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
`include "defines.v"

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
  
  reg[15:0] count;
  
  always @(posedge clk) begin  //写是上升沿
    if(rst == `Enable) begin
      signal_out <= 1'b0;
      count <= 16'd0;
    end else begin
      if(en == `Enable && addr == 32'hfffffd10 && we == `Enable) begin //使能有效  地址正确  并且是写操作
        if(data_in != 32'd0)begin
          signal_out <= 1'b1;
        end else begin
          signal_out <= 1'b0;
        end
      end
    end
  end
  
  always @(*) begin //读是随时读
    if(rst == `Enable)begin
      data_out <= `ZeroWord;
    end else if(en == `Enable && addr == 32'hfffffd10 && we == `Disable) begin
      data_out <= {28'h0000000,3'b000,signal_out};
    end else begin
      data_out <= `ZeroWord;
    end
  end

endmodule
