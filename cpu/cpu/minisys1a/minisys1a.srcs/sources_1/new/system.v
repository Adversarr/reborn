`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/02 09:59:27
// Design Name: 
// Module Name: system
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


module system(
  input board_rst, // 板上重置
  input board_clk, // 板上时钟
  
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
  // Clocking
  wire cpu_clk, uart_clk, cpu_rst;
  cuclock clk_inst(
    .clk_in1(board_clk),
    .clk_out1(cpu_clk),
    .clk_out2(uart_clk)
  );
  
  // Between CPU and Bus:
  wire [`WordRange] cpu_bus_addr, cpu_bus_data, bus_cpu_data;
  wire cpu_bus_enable, cpu_bus_is_write, watchdog_rst;
  wire [3:0] cpu_bus_byte_sel;
  
  // Between CPU and IMEM
  wire [`WordRange] imem_cpu_data, cpu_imem_addr;
  wire cpu_imem_en;
  
  // uart相关
  wire upg_clk_o, upg_wen_o, upg_done_o, upg_rst;
  wire[14:0] upg_adr_o;
  wire[`WordRange] upg_dat_o;

  // Interruption
  wire [5:0] interrupts;
  assign interrupts = 6'b000000;
  // Reset CPU
  assign cpu_rst = board_rst | !upg_rst | watchdog_rst;
  cpu cpu_inst(
    .rst                      (cpu_rst),
    .clk                      (cpu_clk),
    .imem_data_in             (imem_cpu_data),
    .imem_addr_out            (cpu_imem_addr),
    .imem_e_out               (cpu_imem_en),
    .bus_addr_out             (cpu_bus_addr),
    .bus_write_data_out       (cpu_bus_data),
    .bus_eable_out            (cpu_bus_enable),
    .bus_we_out               (cpu_bus_is_write),
    .bus_byte_sel_out         (cpu_bus_byte_sel),
    .bus_data_in              (bus_cpu_data),
    .interrupt_in             (interrupts)
  );
  imem imem_inst(
    .clk                  (~cpu_clk),
    .addr                 (cpu_imem_addr),
    .data_out             (imem_cpu_data),
    .upg_rst              (upg_rst),
    .upg_clk              (upg_clk_o),
    .upg_wen              (upg_wen_o & !upg_adr_o[14]),
    .upg_adr              (upg_adr_o[13:0]),
    .upg_dat              (upg_dat_o),
    .upg_done             (upg_done_o)
  );

  
  bus bus_inst(
    .clk(~cpu_clk),
    .rst(cpu_rst),
    .switches_in(switches_in),
    .buttons_in(buttons_in),
    .keyboard_cols_in(keyboard_cols_in),
    .keyboard_rows_out(keyboard_rows_out),
    .digits_sel_out(digits_sel_out),
    .beep_out(beep_out),
    .led_RLD_out(led_RLD_out),
    .led_GLD_out(led_GLD_out),
    .led_YLD_out(led_YLD_out),
    .addr(cpu_bus_addr),
    .byte_sel(cpu_bus_byte_sel),
    .write_data(cpu_bus_data),
    .enable(cpu_bus_enable),
    .is_write(cpu_bus_is_write),
    .data_out(bus_cpu_data),
    .upg_rst                (upg_rst),
    .upg_clk                (upg_clk_o),
    .upg_wen                (upg_wen_o),
    .upg_adr                (upg_adr_o),
    .upg_dat                (upg_dat_o),
    .upg_done               (upg_done_o),
    .watchdog_cpu_rst(watchdog_rst)
  );
  uart uart_inst(
    .board_clk  (board_clk),
    .board_rst  (board_rst),
    .uart_clk		(uart_clk),		// 10MHz
    .uart_button(buttons_in[3]),
    // blkram signals
    .upg_rst_o    (upg_rst),
    .upg_clk_o    (upg_clk_o),
    .upg_wen_o    (upg_wen_o),
    .upg_adr_o    (upg_adr_o),
    .upg_dat_o    (upg_dat_o),
    .upg_done_o    (upg_done_o),
    // uart signals
    .upg_rx_i    (rx),
    .upg_tx_o    (tx)
  );
endmodule
