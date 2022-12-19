`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/02 10:02:20
// Design Name: 
// Module Name: bus
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
//  UART DATA is unused.
// 
//////////////////////////////////////////////////////////////////////////////////
`include "defines.v"

module bus(
  // <- board
  input wire clk, input wire rst,
  // 开关
  input wire[23:0] switches_in,
  // 按钮
  input wire[4:0] buttons_in,
  // 矩阵键盘
  input wire[3:0] keyboard_cols_in,
  output wire[3:0] keyboard_rows_out,
  // 数砝???
  output wire[7:0] digits_sel_out,
  output wire[7:0] digits_data_out,
  // 蜂鸣???
  output wire beep_out,
  // LED???
  output wire[7:0] led_RLD_out,
  output wire[7:0] led_YLD_out,
  output wire[7:0] led_GLD_out,
  // <- CPU
  input wire [`WordRange] addr,
  input wire [`WordRange] write_data,
  input wire enable,
  input wire is_write,
  input wire [3:0] byte_sel,
  // -> CPU
  output reg [`WordRange] data_out,
  // <- UART
  input wire upg_rst,
  input wire upg_clk,
  input wire upg_wen,
  input wire[14:0] upg_adr,
  input wire[`WordRange] upg_dat,
  input wire upg_done,
  output wire watchdog_cpu_rst
  );
  wire [`WordRange] led_data_out, dmem_data, digit7_data, buzzer_data,
    pwm_data, led_light_data, switch_data, uart_data, watch_dog_data, 
    counter_data, keyboard_data;
 
  mem_for_test data_ram(
    .clk                    (clk),
    .enable                 (enable),
    .we                     (is_write),
    .addr                   (addr),
    .byte_sel               (byte_sel),
    .data_in                (write_data),
    .data_out               (dmem_data),
    .upg_rst                (upg_rst),
    .upg_clk                (upg_clk),
    // TODO: check
    .upg_wen                (upg_wen & upg_adr[14]),
    .upg_adr                (upg_adr[13:0]),
    .upg_dat                (upg_dat),
    .upg_done               (upg_done)
  );
  
  // LED
  leds leds_inst(
    .rst(rst),
    .clk(clk),
    .addr(addr),
    .en(enable),
    .data_in(write_data),
    .we(is_write),
    .data_out(led_data_out),
    // LED Data Actual:
    .RLD(led_RLD_out),
    .YLD(led_YLD_out),
    .GLD(led_GLD_out)
  );

  switches switch_inst(
    .rst(rst),
    .clk(clk),
    .addr(addr),
    .en(enable),
    .data_in(write_data),
    .we(is_write),
    .data_out(switch_data),
    .switch_in(switches_in)
  );
  beep beep_inst(
    .rst(rst),
    .clk(clk),
    .addr(addr),
    .en(enable),
    .data_in(write_data),
    .we(is_write),
    .data_out(keyboard_data),
    .signal_out(beep_out)
  );
  keyboard keys_inst(
      .rst(rst),
      .clk(clk),
      .addr(addr),
      .en(enable),
      .data_in(write_data),
      .we(is_write),
      .data_out(keyboard_data),
      .cols(keyboard_cols_in),
      .rows(keyboard_rows_out)
  );
  pwm pwm_inst(
     .rst(rst),
     .clk(clk),
     .addr(addr),
     .en(enable),
     .data_in(write_data),
     .we(is_write),
     .data_out(keyboard_data)
  );
  digits_roting digit7_inst(
    .rst(rst),
    .clk(clk),
    .addr(addr),
    .en(enable),
    .data_in(write_data),
    .we(is_write),
    .data_out(digit7_data),
    .sel_out(digits_sel_out),
    .digital_out(digits_data_out)
  );
  timer_interface timer_inst(
    .rst(rst),
    .clk(clk),
    .addr(addr),
    .en(enable),
    .data_in(write_data),
    .we(is_write),
    .data_out(counter_data),
    .external_pulse(`Enable)
  );
  watchdog watchdog_inst(
   .rst(rst),
   .clk(clk),
   .addr(addr),
   .en(enable),
   .data_in(write_data),
   .we(is_write),
   .cpu_rst(watchdog_cpu_rst)
  );

  // uart, unused:
  assign uart_data = 32'h00000000;
  
  // 总线仲裝，仅输出
  always @(*)begin
      if (!enable || is_write) begin
        data_out = 32'h0000_0000;
      end else if(addr[31:16] == 16'h0000)begin
          data_out = dmem_data;
      end else if(addr[31:10] == {20'hfffff,2'b11})begin
          case (addr[9:4])
              `IO_SEVEN_DISPLAY: begin
                  data_out = digit7_data;
              end
              `IO_BUZZER: begin
                  data_out = buzzer_data;
              end
              `IO_PWM: begin
                  data_out = pwm_data;
              end
              `IO_LED_LIGHT: begin
                  data_out = led_light_data;
              end
              `IO_SWITCH: begin
                  data_out = switch_data;
              end
              `IO_UART: begin
                  data_out = uart_data;
              end
              `IO_WATCH_DOG: begin
                  data_out = watch_dog_data;
              end
              `IO_COUNTER: begin
                  data_out = counter_data;
              end
              `IO_KEYBORAD: begin
                  data_out = keyboard_data;
              end
              default: begin
                  data_out = `ZeroWord;
              end
          endcase
      end else begin
          data_out = `ZeroWord;
      end
  end
endmodule
