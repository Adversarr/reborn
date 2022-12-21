`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/02 10:02:20
// Design Name: 
// Module Name: keyboard
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


module keyboard(
  input rst, // 复位
  input clk, // 时钟
  // 防抖的灵敏度取决于clk的频率（采样频率），可考虑对clk进行倍频

  //从总线来的数据 所有外设驱动都应有以下信号
  input wire[`WordRange] addr,
  input wire en, // 使能
  input wire[3:0] byte_sel,
  input wire[`WordRange] data_in, // 数据输入（来自cpu）
  input wire we, //写使能

  //发送给仲裁器 所有外设都应有此输出
  output reg [`WordRange] data_out,// 内部端口寄存器 存储按下的值 若无键按下则全f


  input[3:0] cols, // 列线（输入线）  外设输入
  output reg[3:0] rows // 行线（输出线） 发给外设

);
  // 计数器
  reg[15:0] count;
  // 内部寄存器
  reg [3:0] query;
  reg [3:0] is_pressed [3:0];
  
  
  reg internal_clk;
  
  // 去抖
  wire [3:0] s_cols;
  BUFG u0(.I(cols[0]), .O(s_cols[0])); 
  BUFG u1(.I(cols[1]), .O(s_cols[1]));
  BUFG u2(.I(cols[2]), .O(s_cols[2]));
  BUFG u3(.I(cols[3]), .O(s_cols[3]));  
    
  always @(posedge clk) begin
    if (rst) begin
      count <= 0;
      rows <= 4'b1111;
      is_pressed[0] <= 0;
      is_pressed[1] <= 0;
      is_pressed[2] <= 0;
      is_pressed[3] <= 0;
    end else begin
      // read logic.
      if (en == `Enable) begin
        if (we && addr == 32'hFFFF_FC10) begin
          // key value register.
          query <= data_in[3:0];
        end else if (!we) begin
          // query register
//          case (query)
//            4'h0: data_out <= {31'b0, is_pressed[0][3]};
//            4'h1: data_out <= {30'b0, is_pressed[0][0], 1'b0};
//            4'h2: data_out <= {29'b0, is_pressed[1][0], 2'b0};
//            4'h3: data_out <= {28'b0, is_pressed[2][0], 3'b0};
//            4'h4: data_out <= {27'b0, is_pressed[0][1], 4'b0};
//            4'h5: data_out <= {26'b0, is_pressed[1][1], 5'b0};
//            4'h6: data_out <= {25'b0, is_pressed[2][1], 6'b0};
//            4'h7: data_out <= {24'b0, is_pressed[0][2], 7'b0};
//            4'h8: data_out <= {23'b0, is_pressed[1][2], 8'b0};
//            4'h9: data_out <= {22'b0, is_pressed[2][2], 9'b0};
//            4'ha: data_out <= {21'b0, is_pressed[3][0], 10'b0};
//            4'hb: data_out <= {20'b0, is_pressed[3][1], 11'b0};
//            4'hc: data_out <= {19'b0, is_pressed[3][2], 12'b0};
//            4'hd: data_out <= {18'b0, is_pressed[3][3], 13'b0};
//            4'he: data_out <= {17'b0, is_pressed[2][3], 14'b0};
//            4'hf: data_out <= {16'b0, is_pressed[1][3], 15'b0};
//          endcase
          data_out <= {16'b0, is_pressed[0], is_pressed[1], is_pressed[2], is_pressed[3]};
        end
      end
      // scan logic.
      count <= count + 1;
      if (count == 0) begin
        // scan
        case (rows)
          4'b1111: begin
            // begin scan.
            rows <= 4'b0111;
          end
          4'b0111: begin
            is_pressed[0] <= ~s_cols;
            rows <= 4'b1011;
          end
          
          4'b1011: begin
            is_pressed[1] <= ~s_cols;
            rows <= 4'b1101;
          end
          
          4'b1101: begin
            is_pressed[2] <= ~s_cols;
            rows <= 4'b1110;
          end
          
          4'b1110: begin
            is_pressed[3] <= ~s_cols;
            rows <= 4'b0111;
          end
          
          default: begin
            // reset.
            rows <= 4'b1111;
          end
        endcase
      end
    end
  end
endmodule
