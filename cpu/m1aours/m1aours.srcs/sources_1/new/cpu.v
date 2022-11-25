//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/11/15 11:49:34
// Design Name: 
// Module Name: cpu
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

module cpu(
  input wire clk, // CPU Clock
  input wire rst, // Reset Signal From MiniSys
  input wire [`WordRange] instr_memory_in, // Inst: Minisys Instr Mem -> CPU
  input wire [`WordRange] bus_data_in,     // Data read from Bus / Memory.
  input wire [5:0] interrupt_in,           // External Interrupt Signal
  output wire [`WordRange] instr_addr_out, // Addr: CPU -> Instr Memory
  // output wire instr_memory_enable_out,     // Instr memory enable
  output wire [`WordRange] bus_addr_out,   // Bus IO Address
  output wire [`WordRange] bus_data_out,   // Data write to Bus (io/mem)
  output wire bus_enable_out,              // Bus Enable (I/O)
  output wire bus_write_out,               // Bus write enable(Output only)
  output wire [3:0] bus_byte_sel_out       // Bus select to control bus.
);
  /**************************************************************
   * Stage Signals
   **************************************************************/
  
  ///> Stage IF **************************************************
  wire[`WordRange] if_pc_out;
  wire [`WordRange] if_instr;
  // NOTE: Branch: e.g. j, jr, jal, bne, ....
  wire branch_enable;
  wire[`WordRange] branch_addr;
  wire[`WordRange] interrupt_addr;
  ///< Stage IF **************************************************
  
  ///> Stage ID **************************************************
  // ID Inputs:
  wire [`WordRange] id_instr;
  wire [`WordRange] id_pc;
  wire [`WordRange] reg1_data;
  wire [`WordRange] reg2_data;
  wire ex_write_reg_enable;
  wire [`WordRange] ex_write_reg_data;
  wire [`RegRangeLog2] ex_write_reg_addr;
  wire mem_write_reg_enable;
  wire [`WordRange] mem_write_reg_data;
  wire [`RegRangeLog2] mem_write_reg_addr;
  wire id_is_in_delayslot_in;
  // ID Outputs:
  wire [`ALUOpRange] id_aluop_out;
  wire id_reg1_read_enable;
  wire id_reg2_read_enable;
  wire [`WordRange] id_reg1_read_addr_out;   // => RegFile
  wire [`WordRange] id_reg2_read_addr_out;   // => RegFile
  wire [`WordRange] id_data1_out, id_data2_out; // => ALU
  wire id_reg_write_enable;
  wire [`RegRangeLog2] id_reg_write_addr;

  wire id_is_in_delayslot_out, id_next_is_in_delayslot;
  wire [`WordRange] id_instr_out;
  wire [`WordRange] id_link_addr;
  wire id_branch_enable;
  wire [`WordRange] id_branch_addr;
  wire [`WordRange] id_abnormal_type_out, id_current_id_pc_addr_out;
  ///< Stage ID **************************************************
  
  ///> Stage EX **************************************************
  wire [`ALUOpRange] ex_aluop_in;
  wire [`WordRange]  ex_data1_in, ex_data2_in;
  wire ex_reg_write_enable_in;
  wire [`WordRange] ex_instr_in;
  wire [`RegRangeLog2] ex_reg_write_addr_in;
  wire [`WordRange] ex_link_addr_in;
  wire ex_is_in_delayslot_in, ex_next_is_in_delayslot_in;
  wire [`WordRange] ex_current_pc_addr_in, ex_abnormal_type_in;
  ///< Stage EX **************************************************
  ///> Pipeline Controll signals
  wire pause_pc;
  wire pause_if;
  wire pause_id;
  wire pause_ex;
  wire pause_mem;
  wire pause_wb;
  wire id_pause_req;
  wire ex_pause_req;
  wire mem_abnormal_type_out;
  wire mem_cp0_epc_in;
  wire interrupt_pc_out;
  wire interrupt_enable;
  
  // Instr from IMem should be corr. to if_pc.
  assign instr_addr_out = if_pc_out;
  stage_if if_inst(
    .clk(clk),
    .rst(rst),
    .if_pc(if_pc_out),
    .if_instr(if_instr),
    .instr_memory_in(instr_memory_in),
    .pause(pause_pc),
    .branch_enable_in(branch_enable),
    .branch_addr_in(branch_addr),
    .interrupt_enable_in(interrupt_enable),
    .interrupt_addr_in(interrupt_addr)
  );
  
  tran_if_id tran_if_id_inst(
    .clk(clk),
    .rst(rst),
    .if_pc(if_pc_out),
    .if_instr(if_instr),
    .id_pc(id_pc),
    .id_instr(id_instr),
    .pause(pause_if),
    .interrupt_enable_in(interrupt_enable)
  );

  stage_id id_inst(
    .rst(rst),
    .pc_in(id_pc),
    .ins_in(id_instr),
    .reg1_data_in(reg1_data),
    .reg2_data_in(reg2_data),
    .reg1_read_enable_out(id_reg1_read_enable),
    .reg2_read_enable_out(id_reg2_read_enable),
    .reg1_read_addr_out(id_reg1_read_addr_out),
    .reg2_read_addr_out(id_reg2_read_addr_out),
    .alu_op_out(id_aluop_out),
    .data1_out(id_data1_out),
    .data2_out(id_data2_out),
    .reg_write_enable_out(id_reg_write_enable),
    .reg_write_addr_out(id_reg_write_addr),
    .ex_write_reg_enable_in(ex_write_reg_enable),
    .ex_write_reg_data_in(ex_write_reg_data),
    .ex_write_reg_addr_in(ex_write_reg_addr),
    .mem_write_reg_enable_in(mem_write_reg_enable),
    .mem_write_reg_data_in(mem_write_reg_data),
    .mem_write_reg_addr_in(mem_write_reg_addr),
    .pause_out(id_pause_req),
    .is_in_delayslot_in(id_is_in_delayslot_in),
    .is_in_delayslot_out(id_is_in_delayslot_out),
    .next_is_in_delayslot_out(id_next_is_in_delayslot),
    .branch_enable_out(id_branch_enable),
    .branch_addr_out(id_branch_addr),
    .link_addr_out(id_link_addr),
    .ins_out(id_instr_out),
    .abnormal_type_out(id_abnormal_type_out),
    .current_id_pc_addr_out(id_current_id_pc_addr_out)
  );

  tran_id_ex id_ex_inst (
    .clk                      (clk),
    .rst                      (rst),
    // Instruction:
    .id_instr                   (id_instr_out),
    .ex_instr                   (ex_instr_in),
  
    // ALU, data, wreg
    .id_aluop                 (id_aluop_out),
    .id_data1                 (id_data1_out),
    .id_data2                 (id_data2_out),
    .id_write_reg_addr        (id_reg_write_addr),
    .id_write_reg_enable      (id_reg_write_enable),
    .ex_aluop                 (ex_aluop_in),
    .ex_data1                 (ex_data1_in),
    .ex_data2                 (ex_data2_in),
    .ex_write_reg_addr        (ex_reg_write_addr_in),
    .ex_write_reg_enable      (ex_reg_write_enable_in),
    // linkaddr
    .id_link_addr             (id_link_addr),
    .ex_link_addr             (ex_link_addr_in),
    // DelaySlot
    .id_is_in_delayslot       (id_is_in_delayslot_out),
    .id_next_is_in_delayslot  (id_next_is_in_delayslot_out),
    .ex_is_in_delayslot          (ex_is_in_delayslot_in),
    .ex_next_is_in_delayslot  (ex_next_is_in_delayslot_in),
    // Pipeline
    .pause                 (pause_ex),
    .interrupt_enable         (interrupt_enable),
    .id_current_pc_addr       (id_current_id_pc_addr_out),
    .id_abnormal_type         (id_abnormal_type_out),
    .ex_current_pc_addr       (ex_current_pc_addr_in),
    .ex_abnormal_type         (ex_abnormal_type_in)
  );
  
  


endmodule












