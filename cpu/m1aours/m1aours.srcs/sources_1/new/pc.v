`include "public.v"

module pc(
  input clk,
  input rst,
  output reg[`WordRange] pc,  // register PC value
  input wire pause,           // pause from pipeline controller
  input wire branch_enable_in,// branch
  input wire [`WordRange] branch_addr_in,
  input wire interrupt_enable_in,
  input wire [`WordRange] interrupt_addr_in
);

  always @(posedge clk) begin
    if (rst == `Enable) begin
      // When reset => pc = 0
      pc <= `ZeroWord;
    end else if(interrupt_enable_in == `Enable) begin
      // When Interrupted => pc = interrupt_addr
      pc <= interrupt_addr_in;
    end else if (pause == `Enable) begin
      // When paused => do nothing.
      pc <= pc;
    end else if (branch_enable_in == `Enable) begin
      // When branch => pc = branch_addr_in
      pc <= branch_addr_in;
    end else begin
      // Otherwise, pc = pc + 4.
      pc <= pc + 32'd4;
    end
  end

endmodule