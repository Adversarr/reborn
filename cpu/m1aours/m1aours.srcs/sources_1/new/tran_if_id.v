`include "public.v"

module tran_if_id(
  input wire clk, 
  input wire rst,
  input wire[`WordRange] if_pc, 		// PC from IF
  input wire[`WordRange] if_instr, 		// Instruction corr. to if_pc
  
  output reg[`WordRange] id_pc, 		// PC of stage ID.
  output reg[`WordRange] id_instr, 		// Instruction corr. to id_pc 
  
  input wire pause, // pipeline pause.
  
  // interruption.
  input wire interrupt_enable_in
);
 always @(posedge clk) begin
    if (rst == `Enable) begin
      // reset => zero
      id_pc   <= `ZeroWord;
      id_instr  <= `ZeroWord;
    end else if (interrupt_enable_in == `Enable) begin
      // Interruption Flush
      id_pc   <= `ZeroWord;
      id_instr  <= `ZeroWord;
    end else if (pause == `Enable) begin
      // pause => do nothing
      id_pc   <= id_pc;
      id_instr  <= id_instr;
    end else begin
      // default...
      id_pc   <= if_pc;
      id_instr  <= if_instr;
    end
  end


endmodule