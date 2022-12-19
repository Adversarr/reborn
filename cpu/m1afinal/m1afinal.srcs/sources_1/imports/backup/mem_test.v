`include "defines.v"

module mem_for_test(
  //cpu
  input wire clk,
  input wire enable,
  input wire we,
  input wire[`WordRange] addr,
  input wire[3:0] byte_sel,
  input wire[`WordRange] data_in,
  output wire[`WordRange] data_out,
  
  //uart
  input wire upg_rst,
  input wire upg_clk,
  input wire upg_wen,
  input wire[13:0] upg_adr,
  input wire[31:0] upg_dat,
  input wire upg_done);
  // WARN: Byte selecting will not take effect in this test!
  wire kickOff = upg_rst | (~upg_rst & upg_done);
  wire weA,weB,weC,weD;
  
  blk_mem_gen_1 ram_unique(
    .addra         (kickOff ?   addr[15:2]      :   upg_adr),
    .clka          (kickOff ?   clk             :   upg_clk),
    .dina          (kickOff ?   data_in         :   upg_dat),
    .douta         (data_out),
    .wea           (kickOff ?   weA             :   upg_wen)
  );
endmodule