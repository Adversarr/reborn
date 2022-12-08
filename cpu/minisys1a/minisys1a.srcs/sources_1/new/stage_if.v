`include "public.v"

module stage_if(
  input wire clk, 
  input wire rst,
  output wire[`WordRange] pc,
  input wire pause,
  input wire branch_en_in,
  input wire [`WordRange] branch_addr_in,
  input wire flush,
  input wire [`WordRange] interrupt_pc,
  input wire [`WordRange] imem_data,
  output wire [`WordRange] imem_addr,
  output wire [`WordRange] if_ins,
  output wire imem_en
  );
 // IF
 pc  u_pc (
   .clk                      (~clk),
   .rst                      (rst),
   .pc                       (pc),
   .pause                    (pause),
   .branch_en_in             (branch_en_in),
   .branch_addr_in           (branch_addr_in),
   .flush                    (flush),
   .interrupt_pc             (interrupt_pc)
 );
 
 // TODO: add imem cache.
 assign imem_addr = pc;
 assign if_ins = imem_data;
 assign imem_en = 1'b1;
endmodule 