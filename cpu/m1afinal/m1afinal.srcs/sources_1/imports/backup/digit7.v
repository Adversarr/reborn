//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/02 10:02:20
// Design Name: 
// Module Name: digit7
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

module digit7(
  input rst, // 复位
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
  output reg[7:0] sel_out, // 位使能
  output reg[7:0] digital_out // 段使能（DP, G-A）
  );

  always @(posedge clk) begin  //写是上升沿
    if (rst == `Enable) begin
      sel_out <= 8'hff;
      digital_out <= 8'hff;
    end else if(addr == 32'hfffffc00 && en == `Enable && we == `Enable) begin //写的是显示数据寄存器 且使能有效
      case (data_in[7:0])
        //                GFE_DCBA
        8'd0: begin
          digital_out <= 8'b1100_0000; // ABCDEF
        end
        8'd1: begin
          digital_out <= 8'b1111_1001; // BC
        end
        8'd2: begin
          digital_out <= 8'b1010_0100; // ABDEG
        end
        8'd3: begin
          digital_out <= 8'b1011_0000; // ABCDG
        end
        8'd4: begin
          digital_out <= 8'b1001_1001; // BCFG
        end
        8'd5: begin
          digital_out <= 8'b1001_0010; // ACDFG
        end
        8'd6: begin
          digital_out <= 8'b1000_0010; // ACDEFG
        end
        8'd7: begin
          digital_out <= 8'b1111_1000; // ABC
        end
        8'd8: begin
          digital_out <= 8'b1000_0000; // ABCDEFG
        end
        8'd9: begin
          digital_out <= 8'b1001_1000; // ABCFG
        end
        8'd10: begin
          digital_out <= 8'b1000_1000; // ABCEFG
        end
        8'd11: begin
          digital_out <= 8'b1000_0011; // CDEFG
        end
        8'd12: begin
          digital_out <= 8'b1010_0111; // DEG
        end
        8'd13: begin
          digital_out <= 8'b1010_0001; // BCDEG
        end
        8'd14: begin
          digital_out <= 8'b1000_0110; // ADEFG
        end
        8'd15: begin
          digital_out <= 8'b1000_1110; // AEFG
        end
        8'd16: begin
          digital_out <= 8'b1100_0001; // BCDEF --(U)
        end
        8'd17: begin
          digital_out <= 8'b1001_0001; // BCDFG --(y)
        end
      endcase
    end else if(addr == 32'hfffffc04 && en == `Enable && we == `Enable)begin //写的是位数使能寄存器
        sel_out <= ~(1'b1 << data_in[7:0]); //这里存疑 实现方式可以更改
    end
  end

  always @(*) begin
    if(rst == `Enable) begin
      data_out <= `ZeroWord;
    end else if (addr == 32'hfffffc00 && en == `Enable && we ==`Disable) begin
      data_out <= {24'b000000,data_out};
    end else if (addr == 32'hfffffc04 && en == `Enable && we == `Disable) begin
      data_out <= {24'b000000,sel_out};
    end else begin
      data_out <= `ZeroWord;
    end
  end

endmodule
