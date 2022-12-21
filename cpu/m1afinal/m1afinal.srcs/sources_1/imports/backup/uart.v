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

  

endmodule