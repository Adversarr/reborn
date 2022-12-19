//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2014 leishangwen@163.com                       ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
// Module:  openmips_min_sopc
// File:    openmips_min_sopc.v
// Author:  Lei Silei
// E-mail:  leishangwen@163.com
// Description: 基于OpenMIPS处理器的一个简单SOPC，用于验证具备了
//              wishbone总线接口的openmips，该SOPC包含openmips、
//              wb_conmax、GPIO controller、flash controller，uart 
//              controller，以及用来仿真flash的模块flashmem，在其中
//              存储指令，用来仿真外部ram的模块datamem，在其中存储
//              数据，并且具有wishbone总线接口    
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module minisys1a(
	input	wire										clk,
	input wire										rst,
  // 拨码开关
  input wire[23:0] switches_in,
  // 按钮
  input wire[4:0] buttons_in,
  // 矩阵键盘
  input wire[3:0] keyboard_cols_in,
  output wire[3:0] keyboard_rows_out,
  // 数码管
  output wire[7:0] digits_sel_out,
  output wire[7:0] digits_data_out,
  // 蜂鸣器
  output wire beep_out,
  // LED灯
  output wire[7:0] led_RLD_out,
  output wire[7:0] led_YLD_out,
  output wire[7:0] led_GLD_out,

  input wire rx, //UART接收
  output wire tx // UART发送
);

  //连接指令存储器
  wire[`InstAddrBus] inst_addr;
  wire[`InstBus] inst;
  wire rom_ce;
  wire mem_we_i;
  wire[`RegBus] mem_addr_i;
  wire[`RegBus] mem_data_i;
  wire[`RegBus] mem_data_o;
  wire[3:0] mem_sel_i; 
  wire mem_ce_i;   
  wire[5:0] int;
  wire timer_int;
  
  wire watchdog_rst;
  
  
  //assign int = {5'b00000, timer_int, gpio_int, uart_int};
  assign int = {5'b00000, timer_int};
  // uart相关
  wire upg_clk, upg_we, upg_done, upg_rst, start_pg;
  wire[14:0] upg_addr;
  wire[`WordRange] upg_data;
  wire uart_clk, cpuclk;
  wire cpu_rst = rst | (upg_rst | (~upg_rst & upg_done));
  //TODO: for now, watchdog does not take effect! watchdog_rst;
  assign start_pg = buttons_in[3];
  clkdiv clkdiv0 (
    .clk_in1(clk),
    .cpuclk(cpuclk),
    .uartclk(uart_clk)
  );

  uart uart_inst(
    .board_clk  (clk),
    .board_rst  (rst),
    .uart_clk    (uart_clk),    // 10MHz
    .uart_button(buttons_in[3]),
    // blkram signals
    .upg_rst_o    (upg_rst),
    .upg_clk_o    (upg_clk),
    .upg_wen_o    (upg_we),
    .upg_adr_o    (upg_addr),
    .upg_dat_o    (upg_data),
    .upg_done_o    (upg_done),
    // uart signals
    .upg_rx_i    (rx),
    .upg_tx_o    (tx)
  );

  inst_rom inst_rom0(
    .clk(clk),
    .addr(inst_addr),
    .inst(inst),
    // uart:
    .upg_rst_i(upg_rst),
    .upg_clk_i(upg_clk),
    .upg_wen_i(upg_we),
    .upg_addr_i(upg_addr),
    .upg_data_i(upg_data),
    .upg_done_i(upg_done)
  );

  bus bus0(
    .clk(~cpuclk),
    .rst(rst),
    .switches_in(switches_in),
    .buttons_in(buttons_in),
    .keyboard_cols_in(keyboard_cols_in),
    .keyboard_rows_out(keyboard_rows_out),
    .digits_sel_out(digits_sel_out),
    .digits_data_out(digits_data_out),
    .beep_out(beep_out),
    .led_RLD_out(led_RLD_out),
    .led_GLD_out(led_GLD_out),
    .led_YLD_out(led_YLD_out),
    .addr(mem_addr_i),
    .byte_sel(mem_sel_i),
    .write_data(mem_data_i),
    .enable(`Enable),
    .is_write(mem_we_i),
    .data_out(mem_data_o),
    .upg_rst                (upg_rst),
    .upg_clk                (upg_clk),
    .upg_wen                (upg_we),
    .upg_adr                (upg_addr),
    .upg_dat                (upg_data),
    .upg_done               (upg_done),
    .watchdog_cpu_rst       (watchdog_rst)
  );

  openmips cpu0(
    .clk(cpuclk),
    .rst(rst),
    .rom_addr_o(inst_addr),
    .rom_data_i(inst),
    .rom_ce_o(rom_ce),
    .int_i(int),
    .ram_we_o(mem_we_i),
    .ram_addr_o(mem_addr_i),
    .ram_sel_o(mem_sel_i),
    .ram_data_o(mem_data_i),
    .ram_data_i(mem_data_o),
    .ram_ce_o(mem_ce_i),
    .timer_int_o(timer_int)
  );
endmodule