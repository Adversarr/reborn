`include "defines.v"
module uart(
  input wire board_clk,
  input wire board_rst,
  input wire uart_clk,
  input wire uart_button,
  input wire upg_rx_i,
  output wire upg_rst_o,
  output wire upg_tx_o,
  output wire upg_clk_o, 
  output wire upg_wen_o,
  output wire upg_done_o,
  output wire[14:0] upg_adr_o,
  output wire[31:0] upg_dat_o
);

  wire spg_bufg;
  BUFG U1(.I(uart_button), .O(spg_bufg)); 
  //去抖
  reg upg_rst;
  assign upg_rst_o = upg_rst;
  always @(posedge board_clk)begin
    if(spg_bufg)begin
      upg_rst = 0;
    end
    if(board_rst)begin
      upg_rst = 1;
    end
  end
  
  uart_bmpg_0 u_uartpg(
    .upg_clk_i    (uart_clk),    // 10MHz   
    .upg_rst_i    (upg_rst),    // 高电平有效
    // blkram signals
    .upg_clk_o    (upg_clk_o),
    .upg_wen_o    (upg_wen_o),
    .upg_adr_o    (upg_adr_o),
    .upg_dat_o    (upg_dat_o),
    .upg_done_o    (upg_done_o),
    // uart signals
    .upg_rx_i    (upg_rx_i),
    .upg_tx_o    (upg_tx_o)
  );

endmodule