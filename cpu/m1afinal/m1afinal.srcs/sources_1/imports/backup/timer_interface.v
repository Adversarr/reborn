`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/05 15:13:47
// Design Name: 
// Module Name: timer_interface
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


module timer_interface(
  input rst, // 重置
  input clk, // 时钟

  //从???线来的数据 ??有外设驱动都应有以下信号
  input wire[`WordRange] addr,
  input wire en, // 使能
  input wire[3:0] byte_sel,
  input wire[`WordRange] data_in, // 数据输入（来自cpu??
  input wire we, //写使??

  //发???给仲裁?? ??有外设都应有此输??
  output reg[`WordRange] data_out,

  input wire external_pulse
    );

  // 状态寄存器
  reg [16:0] cnt0_value, cnt1_value;
  reg [16:0] cnt0_init_value, cnt1_init_value;
  reg cnt0_valid, cnt1_valid;
  reg cnt0_count_done, cnt1_count_done;
  reg cnt0_timer_done, cnt1_timer_done;
  // 方式寄存
  reg [1:0] cnt0f, cnt1f;
  wire is_enabled_actual = addr[16:4] == 28'hffff_fc2;
  always @(posedge clk) begin
    if (rst == `Enable) begin
      cnt0f <= 1;
      cnt1f <= 1;
      data_out <= 0;
      cnt0_valid <= 0;
      cnt1_valid <= 0;
    end else begin
      // Read Logic...
      if (is_enabled_actual && !we) begin
        if (addr[3:0] == 4'b0000 /* FC20 */) begin
          data_out <= {cnt0_valid, 12'b0000_0000_0000, cnt0_count_done, cnt0_timer_done};
        end else if (addr[3:0] == 4'b0010 /* FC22 */) begin
          data_out <= {cnt1_valid, 12'b0000_0000_0000, cnt1_count_done, cnt1_timer_done};
        end else if (addr[3:0] == 4'b0100 /* FC24 */) begin
          data_out <= cnt0_value;
        end else if (addr[3:0] == 4'b0110 /* FC26 */) begin
          data_out <= cnt1_value;
        end
      end
      
      
      if (we && is_enabled_actual) begin
        if (addr[3:0] == 4'b0000 /* FC20 */) begin
          cnt0f = data_in[1:0];
          cnt0_valid = `Disable;
        end else if (addr[3:0] == 4'b0010 /* FC22 */) begin
          cnt1f = data_in[1:0];
          cnt1_valid = `Disable;
        end else if (addr[3:0] == 4'b0100 /* FC24 */) begin
          cnt0_init_value = data_in[15:0];
          cnt0_value = data_in[15:0];
          cnt0_valid = `Enable;
        end else if (addr[3:0] == 4'b0110 /* FC26 */) begin
          cnt1_init_value = data_in[15:0];
          cnt1_value = data_in[15:0];
          cnt1_valid = `Enable;
        end
      end

      // For timer:
      if (!cnt0f[0]) begin
        if (cnt0_value != 0) begin
          cnt0_value = cnt0_value - 16'b0000_0000_0000_0001;
          cnt0_timer_done = `Disable;
        end else begin
          if (cnt0f[1]) /*Repeat!*/ begin
            cnt0_value = cnt0_init_value;
          end else begin
            cnt0_valid = `Disable;
            cnt0_timer_done = `Enable;
          end
        end
      end
      if (!cnt1f[0]) begin
        if (cnt1_value != 0) begin
          cnt1_value = cnt1_value - 16'b0000_0000_0000_0001;
          cnt1_timer_done = `Disable;
        end else begin
          if (cnt1f[1]) /*Repeat!*/ begin
            cnt1_value = cnt1_init_value;
            cnt1_timer_done = `Enable;
          end else begin
            cnt1_valid = `Disable;
          end
        end
      end
    end
  end

  always @(posedge external_pulse) begin
    if (cnt0f[0]) begin
      if (cnt0_value != 1) begin
        cnt0_value = cnt0_value - 16'b0000_0000_0000_0001;
        cnt0_count_done = `Disable;
      end else begin
        if (cnt0f[1]) /*Repeat*/begin
          cnt0_value = cnt0_init_value;
          cnt0_count_done = `Enable;
        end
      end
    end

    if (cnt1f[0]) begin
      if (cnt1_value != 1) begin
        cnt1_value = cnt1_value - 16'b0000_0000_0000_0001;
        cnt1_count_done = `Disable;
      end else begin
        if (cnt1f[1]) /*Repeat*/begin
          cnt1_value = cnt1_init_value;
          cnt1_count_done = `Enable;
        end
      end
    end
  end
endmodule
