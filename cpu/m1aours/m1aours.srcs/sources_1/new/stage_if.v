`include "public.v"

module stage_if(
  input clk,
  input rst,
  output wire[`WordRange] if_pc,  // register PC value
  output wire[`WordRange] if_instr,
  input wire[`WordRange] instr_memory_in,
  input wire pause,           // pause from pipeline controller
  input wire branch_enable_in,// branch
  input wire [`WordRange] branch_addr_in,
  input wire interrupt_enable_in,
  input wire [`WordRange] interrupt_addr_in
);

  // TODO: if_instr can be cached
  assign if_instr = instr_memory_in;
  pc pc_inst(
    .clk(clk),
    .rst(rst),
    .pc(if_pc),
    .pause(pause),
    .branch_enable_in(branch_enable_in),
    .branch_addr_in(branch_addr_in),
    .interrupt_enable_in(interrupt_enable_in),
    .interrupt_addr_in(interrupt_addr_in)
  );
endmodule