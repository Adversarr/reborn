`include "defines.v"

module inst_rom(
	input	wire										clk,
	input wire[`InstAddrBus]			addr,
	output wire[`InstBus]					inst,
  // uart part
  input wire                    upg_rst_i,
  input wire                    upg_clk_i,
  input wire                    upg_wen_i,
  input wire [14:0]             upg_addr_i,
  input wire [`InstBus]         upg_data_i,
  input wire                    upg_done_i
);
  // kick off
  wire cpu_en = upg_rst_i | (~upg_rst_i & upg_done_i);

  blk_mem_gen_0 imem_inst(
    .addra(cpu_en ? addr[15:2] : upg_addr_i[13:0]),
    .clka(cpu_en ? clk : upg_clk_i),
    .dina(cpu_en ? 32'h0000_0000 : upg_data_i),
    .douta(inst),
    .wea(cpu_en ? 1'b0 : upg_wen_i & !upg_addr_i[14])
  );

endmodule
