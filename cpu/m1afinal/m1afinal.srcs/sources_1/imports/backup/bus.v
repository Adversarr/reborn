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
  input wire cpu_rst,
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
  wire [`WordRange] dmem_data, digit7_data, buzzer_data,
    pwm_data, led_light_data, switch_data, 
    counter_data, keyboard_data;
 
  dmem data_ram(
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
  
  wire [7:0] led_RLD_fake;
  wire [7:0] led_YLD_fake;
  wire [7:0] led_GLD_fake;
  // LED
  leds leds_inst(
    // TODO: reset should be done in bios.
    .rst(cpu_rst),
    .clk(clk),
    .addr(addr),
    .en(enable),
    .data_in(write_data),
    .byte_sel(byte_sel),
    .we(is_write),
    .data_out(led_light_data),
    // LED Data Actual:
    .RLD(led_RLD_fake),
    .YLD(led_YLD_fake),
    .GLD(led_GLD_fake)
  );

  // real, cpurst, upg_wen
  assign led_RLD_out = {led_RLD_fake[7:5], led_RLD_fake[4], led_RLD_fake[3] | upg_done, 
      led_RLD_fake[2] | buttons_in[2], led_RLD_fake[1] | ~upg_rst, led_RLD_fake[0] | upg_wen};
  wire cpu_en = upg_rst | (~upg_rst & upg_done);
  assign led_YLD_out = {1'b0, (!cpu_en ? upg_adr[14:8] : 7'b000_0000)} | led_YLD_fake;
  assign led_GLD_out = (!cpu_en ? upg_adr[7:0] : 7'b000_0000) | led_GLD_fake;

  switches switch_inst(
    .rst(rst),
    .clk(clk),
    .addr(addr),
    .en(enable),
    .data_in(write_data),
    .we(is_write),
    .byte_sel(byte_sel),
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
    .byte_sel(byte_sel),
    .data_out(buzzer_data),
    .signal_out(beep_out)
  );
  keyboard keys_inst(
      .rst(rst),
      .clk(clk),
      .addr(addr),
      .en(enable),
      .data_in(write_data),
      .byte_sel(byte_sel),
      .we(is_write),
      .data_out(keyboard_data),
      .cols(keyboard_cols_in),
      .rows(keyboard_rows_out)
  );
  pwm pwm_inst(
     .rst(rst),
     .clk(clk),
     .addr(addr),
     .byte_sel(byte_sel),
     .en(enable),
     .data_in(write_data),
     .we(is_write),
     .data_out(pwm_data)
  );
  digits_roting digit7_inst(
    .rst(rst),
    .clk(clk),
    .addr(addr),
    .en(enable),
    .data_in(write_data),
    .byte_sel(byte_sel),
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
    .byte_sel(byte_sel),
    .we(is_write),
    .data_out(counter_data),
    .external_pulse(`Enable)
  );
  watchdog watchdog_inst(
   .rst(rst),
   .clk(clk),
   .addr(addr),
   .byte_sel(byte_sel),
   .en(enable),
   .data_in(write_data),
   .we(is_write),
   .cpu_rst(watchdog_cpu_rst)
  );

  // uart, unused:
  wire [31:0] uart_data;
  assign uart_data = 32'h00000000;
  
  // 总线仲裝，仅输出
  always @(*)begin
      if (!enable || is_write) begin
        data_out = 32'h0000_0000;
      end else if(addr[31:16] == 16'h0000)begin
          data_out = dmem_data;
      end else begin
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
                  data_out = 32'h0000_0000;
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
      end
  end
endmodule
