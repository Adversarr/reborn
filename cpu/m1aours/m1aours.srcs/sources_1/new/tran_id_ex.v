//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/11/23 13:44:29
// Design Name: 
// Module Name: tran_id_ex
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
`include "public.v"

module tran_id_ex(
  input clk, input rst,
  // Instruction:
  input wire [`WordRange] id_instr,
  output reg [`WordRange] ex_instr,
  // Alu Operations:
  input wire [`ALUOpRange] id_aluop,
  output reg [`ALUOpRange] ex_aluop,
  // Data for ALU...
  input wire [`WordRange] id_data1,
  input wire [`WordRange] id_data2,
  output reg [`WordRange] ex_data1,
  output reg [`WordRange] ex_data2,
  // Write Register Enable & Address.
  input id_write_reg_enable,
  input wire [`RegRangeLog2] id_write_reg_addr,
  output reg ex_write_reg_enable,
  output reg [`RegRangeLog2] ex_write_reg_addr,
  // Link Addr.
  input wire [`WordRange] id_link_addr,
  output reg [`WordRange] ex_link_addr,
  // Delay Slot
  input wire id_is_in_delayslot,
  input wire id_next_is_in_delayslot,
  output reg ex_is_in_delayslot,
  output reg ex_next_is_in_delayslot,
  // Pipeline Pause
  input wire pause,
  // Interruption:
  input wire interrupt_enable,
  input wire [`WordRange] id_current_pc_addr,
  input wire [`WordRange] id_abnormal_type,
  output reg [`WordRange] ex_current_pc_addr,
  output reg [`WordRange] ex_abnormal_type);
    
  always @(posedge clk) begin
    if (rst == `Enable) begin
      ex_aluop <= `ALUOP_NOP;
      ex_data1 <= `ZeroWord;
      ex_data2 <= `ZeroWord;
      ex_write_reg_enable <= `Disable;
      ex_link_addr <= `ZeroWord;
      ex_is_in_delayslot <= `Disable;
      ex_next_is_in_delayslot <= `Disable;
      ex_instr <= `ZeroWord;
      ex_current_pc_addr <= `ZeroWord;
      ex_abnormal_type <= `ZeroWord;
    end else if(interrupt_enable == `Enable) begin
      ex_aluop <= `ALUOP_NOP;
      ex_data1 <= `ZeroWord;
      ex_data2 <= `ZeroWord;
      ex_write_reg_enable <= `Disable;
      ex_link_addr <= `ZeroWord;
      ex_is_in_delayslot <= `Disable;
      ex_next_is_in_delayslot <= `Disable;
      ex_instr <= `ZeroWord;
      ex_current_pc_addr <= `ZeroWord;
      ex_abnormal_type <= `ZeroWord;
    end else if (pause == `Enable) begin
      ex_aluop <= ex_aluop;
      ex_data1 <= ex_data1;
      ex_data2 <= ex_data2;
      ex_write_reg_enable <= ex_write_reg_enable;
      ex_write_reg_addr <= ex_write_reg_addr;
      ex_link_addr <= ex_link_addr;
      ex_is_in_delayslot <= ex_is_in_delayslot;
      ex_next_is_in_delayslot <= ex_next_is_in_delayslot;
      ex_instr <= ex_instr;
      ex_current_pc_addr <= ex_current_pc_addr;
      ex_abnormal_type <= ex_abnormal_type;
    end else begin
      ex_aluop <= id_aluop;
      ex_data1 <= id_data1;
      ex_data2 <= id_data2;
      ex_write_reg_enable <= id_write_reg_enable;
      ex_write_reg_addr <= id_write_reg_addr;
      ex_link_addr <= id_link_addr;
      ex_is_in_delayslot <= id_is_in_delayslot;
      ex_next_is_in_delayslot <= id_next_is_in_delayslot;
      ex_instr <= id_instr;
      ex_current_pc_addr <= id_current_pc_addr;
      ex_abnormal_type <= id_abnormal_type;
    end
  end
endmodule
