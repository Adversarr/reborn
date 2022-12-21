`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/19 16:23:23
// Design Name: 
// Module Name: digits_roting
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
`timescale 1ns/1ps

module digits_roting(
  input rst, // 复位
  input clk, // 时钟

  //从总线来的数据 所有外设驱动都应有以下信号
  input wire[31:0] addr,
  input wire en, // 使能
  input wire[3:0] byte_sel,
  input wire[31:0] data_in, // 数据输入（来自cpu）
  input wire we, //写使能

  //发送给仲裁器 所有外设都应有此输出
  output reg[31:0] data_out,

  //发送给外设
  output reg[7:0] sel_out, // 位使能
  output wire[7:0] digital_out // 段使能（DP, G-A）
  );
  wire digit_clk;
  reg [3:0] data_hi[3:0];
  reg [3:0] data_lo[3:0];
  reg dot;
  reg [8:0] data_dot  = 0;
  reg [8:0] enable_digit;
  reg [2:0] select = 0;
  wire [6:0] out_digit;
  wire en_actual = en && (addr[31:4] == 28'hFFFF_FC0);
  integer i;
  
  reg dived_clk = 1'b0;
  reg [15:0] internal_cnt = 0;
  assign digit_clk = internal_cnt[13];
    
  
  // update data.
  always @(posedge clk) begin
    internal_cnt <= internal_cnt + 1;
    if (rst) begin
      for (i = 0; i < 4; i = i + 1) begin
        data_hi[i] <= 0;
        data_lo[i] <= 0;
      end
      enable_digit <= 8'b0000_0000;
      data_dot <= 8'b0000_0000;
    end
    
    if (en_actual) begin
      if (!we) begin
        if (addr[3:0] == 4'b0000) begin
          data_out <= {16'h0000, data_lo[3], data_lo[2], data_lo[1]};
        end else if (addr[3:0] == 4'b0010) begin
          data_out <= {16'h0000, data_hi[3], data_hi[2], data_hi[1]};
        end else if (addr[3:0] == 4'b0100) begin
          data_out <= {16'h0000, enable_digit, data_dot};
        end
      end else begin
        if (addr[3:0] == 4'b0000) begin
          data_hi[3] <= data_in[15:12];
          data_hi[2] <= data_in[11:8];
          data_hi[1] <= data_in[7:4];
          data_hi[0] <= data_in[3:0];
        end else if (addr[3:0] == 4'b0010) begin
          data_lo[3] <= data_in[15:12];
          data_lo[2] <= data_in[11:8];
          data_lo[1] <= data_in[7:4];
          data_lo[0] <= data_in[3:0];
        end else if (addr[3:0] == 4'b0100) begin
          data_dot <= data_in[7:0];
          enable_digit <= data_in[15:8];
        end
      end
    end
  end
  
  single_digit sd(
    .din(select[2] ? data_hi[select[1:0]] : data_lo[select[1:0]]),
    .dout(out_digit)
  );
  always @(posedge digit_clk) begin
    if (rst) begin
      select <= 3'h0;
      sel_out <= 8'b1111_1111;
    end else begin
      select = select + 3'h1;
      sel_out = 8'b1111_1111;
      sel_out[select] = ~enable_digit[select];
    end
  end
  
  assign digital_out = {out_digit, data_dot[select]};
endmodule
