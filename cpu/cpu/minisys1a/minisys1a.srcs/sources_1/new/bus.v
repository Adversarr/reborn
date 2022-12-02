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
`include "public.v"

module bus(
  // <- board
  input wire clk, input wire rst,
  // ²¦Âë¿ª¹Ø
  input wire[23:0] switches_in,
  // °´Å¥
  input wire[4:0] buttons_in,
  // ¾ØÕó¼üÅÌ
  input wire[3:0] keyboard_cols_in,
  output wire[3:0] keyboard_rows_out,
  // ÊýÂë¹Ü
  output wire[7:0] digits_sel_out,
  output wire[7:0] digits_data_out,
  // ·äÃùÆ÷
  output wire beep_out,
  // LEDµÆ
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
  input wire upg_done
  );
  wire [`WordRange] led_data_out, dmem_data, digit7_data, buzzer_data,
    pwm_data, led_light_data, switch_data, uart_data, watch_dog_data, 
    counter_data, keyboard_data;
  // Ram
  dmem dmem_inst(
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
  
  // TODO: Impl for switch, beep, keyboard, etc.
  switches switch_inst();
  beep beep_inst();
  keyboard keys_inst();
  pwm pwm_inst();
  digit7 digit7_inst();
  timer timer_inst();
  watchdog watchdog_inst();

  // uart, unused:
  assign uart_data = 32'h00000000;
  
  // ×ÜÏßÖÙ²Ã£¬½öÊä³ö
  always @(*)begin
      if(addr[31:16] == 16'h0000)begin
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
