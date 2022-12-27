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
  
  reg [5:0] status_data = 6'b0000_00;
  
  
  wire watchdog_rst;
  
  
  //assign int = {5'b00000, timer_int, gpio_int, uart_int};
  assign int = {5'b00000, timer_int};
  // uart相关
  wire upg_clk, upg_we, upg_done, start_pg;
  wire [14:0] upg_addr;
  wire [31:0] upg_data;
  wire uart_clk, cpuclk;
  //TODO: for now, watchdog does not take effect! watchdog_rst;
  assign start_pg = buttons_in[2];
  wire spg_bufg;
  BUFG U1(.I(start_pg), .O(spg_bufg)); 
  //去抖
  reg upg_rst;
  always @(posedge clk)begin
    if(spg_bufg)begin
      upg_rst = 0;
    end
    if(rst)begin
      upg_rst = 1;
    end
  end
  wire cpu_rst = rst | !upg_rst;
  
  uart_bmpg_1 u_uartpg(
    .upg_clk_i    (uart_clk),    // 10MHz   
    .upg_rst_i    (upg_rst),    // 高电平有效
    // blkram signals
    .upg_clk_o    (upg_clk),
    .upg_wen_o    (upg_we),
    .upg_adr_o    (upg_addr),
    .upg_dat_o    (upg_data),
    .upg_done_o    (upg_done),
    // uart signals
    .upg_rx_i    (rx),
    .upg_tx_o    (tx)
  );
  
  clkdiv clkdiv0 (
    .clk_in1(clk),
    .cpuclk(cpuclk),
    .uartclk(uart_clk)
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
    .cpu_rst(cpu_rst),
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
    .rst(cpu_rst),
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
