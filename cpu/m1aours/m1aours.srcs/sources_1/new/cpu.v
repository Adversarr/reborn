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
  wire [`ALUOpRange] ex_aluop_in, ex_aluop_out;
  wire [`WordRange]  ex_data1_in, ex_data2_in;
  wire ex_reg_write_enable_in, ex_reg_write_enable_out;
  wire [`RegRangeLog2] ex_reg_write_addr_in;
  wire [`RegRangeLog2] ex_reg_write_addr_out;
  wire [`WordRange] ex_reg_write_data_out;
  wire [`WordRange] ex_instr_in, ex_instr_out;
  wire [`WordRange] ex_link_addr_in;
  wire ex_is_in_delayslot_in, ex_next_is_in_delayslot_in;
  wire [`WordRange] ex_current_pc_addr_in, ex_abnormal_type_in;
  
  wire [`WordRange] ex_hi_data_in, ex_lo_data_in;
  wire ex_hilo_write_enable_out;
  wire [`WordRange] ex_hi_data_out, ex_lo_data_out;
  wire [`WordRange] ex_mem_addr_out, ex_mem_data_out;

  wire [4:0] ex_cp0_raddr_out;
  wire [`WordRange] ex_cp0_data_in;
  wire mem_cp0_write_enable, wb_cp0_write_enable;
  wire [`WordRange] mem_cp0_write_data, wb_cp0_write_data;
  wire [4:0] mem_cp0_write_addr, wb_cp0_write_addr;
  wire ex_cp0_write_enable_out;
  wire [4:0] ex_cp0_write_addr_out;
  wire [`WordRange] ex_cp0_write_data_out;
  
  wire [`WordRange] ex_current_ex_pc_addr_out;
  wire [`WordRange] ex_abnormal_type_out;
  
  ///>///> Multiplication and division **************************************************
  wire [`WordRange] ex_div_data1_signed, ex_div_data2_signed,
                    ex_div_data1_unsigned, ex_div_data2_unsigned,
                    ex_mul_data1, ex_mul_data2;
  wire ex_is_div_data_signed_valid,   ex_is_div_result_signed_valid,
       ex_is_div_data_unsigned_valid, ex_is_div_result_unsigned_valid,
       ex_is_mul_valid, ex_is_mul_signed, ex_is_mul_result_valid;
  wire [`DivMulResultRange] mul_result, signed_div_result, unsigned_div_result;
  ///>///< Multiplication and division **************************************************
  ///< Stage EX **************************************************
  
  ///> Stage MEM **************************************************
  wire mem_write_reg_enable_in, mem_write_reg_enable_out;
  wire [`RegRangeLog2] mem_write_reg_addr_in;
  wire [`WordRange] mem_write_reg_data_in, mem_write_reg_data_out;
  wire [`RegRangeLog2] mem_write_reg_addr_out;
  wire mem_hilo_write_enable_in, mem_hilo_write_enable_out;
  wire [`WordRange] mem_hi_data_out;
  wire [`WordRange] mem_lo_data_out;
  wire [`ALUOpRange] mem_aluop_in, mem_aluop_out;
  wire [`WordRange] mem_addr_in, mem_data_in;
  wire [`WordRange] mem_instr_in;
  wire mem_cp0_write_enable_in;
  wire [4:0] mem_cp0_write_addr_in;
  wire [`WordRange] mem_cp0_write_data_in;
  wire [`WordRange] mem_pc_addr_in, mem_pc_addr_out;
  wire [`WordRange] mem_abnormal_type_in;
  wire mem_cp0_write_enable_out;
  wire [4:0] mem_cp0_write_addr_out;
  wire [`WordRange] mem_cp0_write_data_out;
  wire [`WordRange] mem_cp0_status_in;
  wire [`WordRange] mem_cp0_cause_in;
  ///< Stage MEM **************************************************
  
  ///> Stage WB **************************************************
  wire wb_hilo_write_enable_out;
  wire [`WordRange] wb_hi_data_out, wb_lo_data_out;
  wire wb_write_reg_enable;
  wire [`RegRangeLog2] wb_write_reg_addr;
  wire [`WordRange] wb_write_reg_data, wb_cp0_wdata_in;
  wire [4:0] wb_cp0_waddr_in;
  wire [`WordRange] wb_cp0_write_enable_in;
  wire [`WordRange] wb_cp0_write_addr_in;
  wire [`WordRange] wb_cp0_write_data_in;
  
  ///< Stage WB **************************************************
  
  
  ///> Pipeline Controll signals
  wire pause_pc;
  wire pause_if;
  wire pause_id;
  wire pause_ex;
  wire pause_mem;
  wire pause_wb;
  wire id_pause_req;
  wire ex_pause_req;
  wire [`WordRange] mem_abnormal_type_out;
  wire [`WordRange] mem_cp0_epc_in;
  wire interrupt_pc_out;
  wire interrupt_enable;
  // Pipeline backwarding.
  wire mem_hilo_write_enable;
  wire [`WordRange] mem_hi_data, mem_lo_data;
  wire wb_hilo_write_enable;
  wire [`WordRange] wb_hi_data, wb_lo_data;
  
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
  
  tran_if_id if_id_inst(
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
    .id_next_is_in_delayslot  (id_next_is_in_delayslot),
    .ex_is_in_delayslot          (ex_is_in_delayslot_in),
    .ex_next_is_in_delayslot  (ex_next_is_in_delayslot_in),
    // Pipeline
    .pause                    (pause_ex),
    .interrupt_enable         (interrupt_enable),
    .id_current_pc_addr       (id_current_id_pc_addr_out),
    .id_abnormal_type         (id_abnormal_type_out),
    .ex_current_pc_addr       (ex_current_pc_addr_in),
    .ex_abnormal_type         (ex_abnormal_type_in)
  );
  
  stage_ex ex_inst(
    .rst(rst),
    .aluop_in(ex_aluop_in),
    .data1_in(ex_data1_in),
    .data2_in(ex_data2_in),
    // Reg Write:
    .reg_write_addr_in(ex_reg_write_addr_in),
    .reg_write_enable_in(ex_reg_write_enable_in),
    .reg_write_addr_out(ex_reg_write_addr_out),
    .reg_write_enable_out(ex_reg_write_enable_out),
    .reg_write_data_out(ex_reg_write_data_out),
    // HI LO:
    .hi_data_in(ex_hi_data_in),
    .lo_data_in(ex_lo_data_in),
    // Pipeline backward of HI LO.
    .mem_hilo_write_enable_in(mem_hilo_write_enable),
    .mem_hi_data_in(mem_hi_data),
    .mem_lo_data_in(mem_lo_data),
    .wb_hilo_write_enable_in(wb_hilo_write_enable),
    .wb_hi_data_in(wb_hi_data),
    .wb_lo_data_in(wb_lo_data),
    .hilo_write_enable_out(ex_hilo_write_enable_out),
    .hi_data_out(ex_hi_data_out),
    .lo_data_out(ex_lo_data_out),
    // Pause Request:
    .pause_req(ex_pause_req),
    // Branching:
    .link_addr_in(ex_link_addr_in),
    // TODO: Here is an obvious defect
    // Dividing Operation:
    .div_data1_signed(ex_div_data1_signed),
    .div_data2_signed(ex_div_data2_signed),
    .is_div_data_signed_valid(ex_is_div_data_signed_valid),
    .div_result_signed(signed_div_result),
    .is_div_result_signed_valid(ex_is_div_result_signed_valid),
    // Unsigned Division.
    .div_data1_unsigned(ex_div_data1_unsigned),
    .div_data2_unsigned(ex_div_data2_unsigned),
    .div_result_unsigned(unsigned_div_result),
    .is_div_result_unsigned_valid(ex_is_div_result_unsigned_valid),
    .is_div_data_unsigned_valid(ex_is_div_data_unsigned_valid),
    // Multiplication Operation
    .mul_data1(ex_mul_data1),
    .mul_data2(ex_mul_data2),
    .mul_valid(ex_is_mul_valid),
    .is_mul_signed(ex_is_mul_signed),
    .mul_result(mul_result),
    .mul_result_valid(ex_is_mul_result_valid),
    .is_in_delayslot(ex_is_in_delayslot_in),
    .ins_in(ex_instr_in),
    .ins_out(ex_instr_out),
    .aluop_out(ex_aluop_out),
    .mem_addr_out(ex_mem_addr_out),
    .mem_data_out(ex_mem_data_out),
    .cp0_data_in(ex_cp0_data_in),
    .cp0_raddr_out(ex_cp0_raddr_out),
    // backwarding from MEM and WB:
    .mem_cp0_write_enable_in(mem_cp0_write_enable),
    .mem_cp0_w_addr_in(mem_cp0_write_addr),
    .mem_cp0_w_data_in(mem_cp0_write_data),
    .wb_cp0_write_enable_in(wb_cp0_write_enable),
    .wb_cp0_w_addr_in(wb_cp0_write_addr),
    .wb_cp0_w_data_in(wb_cp0_write_data),
    // ex cp0 output
    .cp0_write_enable_out(ex_cp0_write_enable_out),
    .cp0_waddr_out(ex_cp0_write_addr_out),
    .cp0_w_data_out(ex_cp0_write_data_out),
    // interruption.
    .current_ex_pc_addr_in(ex_current_pc_addr_in),
        .current_ex_pc_addr_out(ex_current_ex_pc_addr_out),
    .abnormal_type_in(ex_abnormal_type_in),
    .abnormal_type_out(ex_abnormal_type_out)
  );
  
  // These modules can be moved into `stage_ex`:
  signed_div signed_div_inst(
    .aclk(clk),
    .s_axis_divisor_tdata(ex_div_data2_signed),
    .s_axis_divisor_tvalid(ex_is_div_data_signed_valid),
    .s_axis_dividend_tdata(ex_div_data1_signed),
    .s_axis_dividend_tvalid(ex_is_div_data_signed_valid),
    .m_axis_dout_tdata(signed_div_result),
    .m_axis_dout_tvalid(ex_is_div_result_signed_valid)
  );
  unsigned_div unsigned_div_inst(
    .aclk(clk),
    .s_axis_divisor_tdata(ex_div_data2_unsigned),
    .s_axis_divisor_tvalid(ex_is_div_data_unsigned_valid),
    .s_axis_dividend_tdata(ex_div_data1_unsigned),
    .s_axis_dividend_tvalid(ex_is_div_data_unsigned_valid),
    .m_axis_dout_tdata(unsigned_div_result),
    .m_axis_dout_tvalid(ex_is_div_result_unsigned_valid)
  );
  mult mult_inst(
    .clk(clk),
    .data1(ex_mul_data1),
    .data2(ex_mul_data2),
    .en(ex_is_mul_valid),
    .is_valid(ex_is_mul_result_valid),
    .is_signed(ex_is_mul_signed),
    .result(mul_result)
  );
  
  tran_ex_mem ex_mem_inst(
    .clk(clk),
    .rst(rst),
    .ex_write_reg_enable(ex_reg_write_enable_out),
    .ex_write_reg_addr(ex_reg_write_addr_out),
    .ex_write_reg_data(ex_reg_write_data_out),
    .mem_write_reg_enable(mem_write_reg_enable_in),
    .mem_write_reg_addr(mem_write_reg_addr_in),
    .mem_write_reg_data(mem_write_reg_data_in),
    .ex_hilo_write_enable(ex_hilo_write_enable_out),
    .ex_hi_data(ex_hi_data_out),
    .ex_lo_data(ex_lo_data_out),
    .mem_hilo_write_enable(mem_hilo_write_enable_in),
    .mem_hi_data(mem_hi_data_in),
    .mem_lo_data(mem_lo_data_in),
    .pause(pause_mem),
    .ex_aluop(ex_aluop_out),
    .ex_mem_addr(ex_mem_addr_out),
    .ex_mem_data(ex_mem_data_out),
    .mem_aluop(mem_aluop_in),
    .mem_addr(mem_addr_in),
    .mem_data(mem_data_in),
    .ex_ins(ex_instr_out),
    .mem_ins(mem_instr_in),
    .ex_cp0_we(ex_cp0_write_enable_out),
    .ex_cp0_waddr(ex_cp0_write_addr_out),
    .ex_cp0_wdata(ex_cp0_write_data_out),
    .mem_cp0_we(mem_cp0_write_enable_in),
    .mem_cp0_waddr(mem_cp0_write_addr_in),
    .mem_cp0_wdata(mem_cp0_write_data_in),
    .flush(interrupt_enable),
    .ex_pc_addr_in(ex_current_ex_pc_addr_out),
    .ex_abnormal_type(ex_abnormal_type_out),
    .mem_pc_addr_out(mem_pc_addr_in),
    .mem_abnormal_type(mem_abnormal_type_in)
  );
  
  stage_mem mem_inst(
    .clk(clk),
    .rst(rst),
    .write_reg_enable_in(mem_write_reg_enable_in),
    .write_reg_data_in(mem_write_reg_data_in),
    .write_reg_addr_in(mem_write_reg_addr_in),
    .write_reg_enable_out(mem_write_reg_enable_out),
    .write_reg_data_out(mem_write_reg_data_out),
    .write_reg_addr_out(mem_write_reg_addr_out),
    .hilo_we_in(mem_hilo_write_enable_in),
    .hi_data_in(mem_hi_data),
    .lo_data_in(mem_lo_data),
    .hilo_we_out(mem_hilo_write_enable_out),
    .hi_data_out(mem_hi_data_out),
    .lo_data_out(mem_lo_data_out),
    .aluop_in(mem_aluop_in),
    .mem_addr_in(mem_addr_in),
    .mem_store_data_in(mem_data_in),
    // MEM is BUS
    .mem_we_out(bus_enable_out),
    .mem_byte_sel_out(bus_byte_sel_out),
    .mem_store_data_out(bus_data_out),
    .mem_enable_out(bus_enable_out),
    .cp0_write_enable_in(mem_cp0_write_data_in),
    .cp0_write_addr_in(mem_cp0_write_addr_in),
    .cp0_write_data_in(mem_cp0_write_data_in),
    .cp0_write_enable_out(mem_cp0_write_enable_out),
    .cp0_write_addr_out(mem_cp0_write_addr_out),
    .cp0_write_data_out(mem_cp0_write_data_out),
    .current_mem_pc_addr_in(mem_pc_addr_in),
    .abnormal_type_in(mem_abnormal_type_in),
    .cp0_status_in(mem_cp0_status_in),
    .cp0_cause_in(mem_cp0_cause_in),
    .cp0_epc_in(mem_cp0_epc_in),
    .abnormal_type_out(mem_abnormal_type_out),
    .current_mem_pc_addr_out(mem_pc_addr_out)
  );
  
  
  // MEM-WB
  tran_mem_wb  mem_wb_inst(
  .rst                      (rst),
  .clk                      (clk),
  .mem_wreg_e               (mem_write_reg_enable_out),
  .mem_wreg_addr            (mem_write_reg_addr_out),
  .mem_wreg_data            (mem_write_reg_data_out),
  .wb_wreg_e                (wb_write_reg_enable),
  .wb_wreg_addr             (wb_write_reg_addr),
  .wb_wreg_data             (wb_write_reg_data),
  .mem_hilo_we              (mem_hilo_write_enable_out),
  .mem_hi_data              (mem_hi_data_out),
  .mem_lo_data              (mem_lo_data_out),
  .wb_hilo_we               (wb_hilo_write_enable),
  .wb_hi_data               (wb_hi_data),
  .wb_lo_data               (wb_lo_data),
  .pause                    (pause_wb),
  .f_mem_cp0_we             (mem_cp0_write_enable_out),
  .f_mem_cp0_waddr          (mem_cp0_write_addr_out),
  .f_mem_cp0_wdata          (mem_cp0_write_data_out),
  .t_wb_cp0_we              (wb_cp0_write_enable_in),
  .t_wb_cp0_waddr           (wb_cp0_write_addr_in),
  .t_wb_cp0_wdata           (wb_cp0_write_data_in),
  .flush                    (interrupt_enable)
  );



//  ppl_scheduler u_ppl_sch(
//  .rst                      (rst),
//  .pause_req_id             (pause_req_id),
//  .pause_req_ex             (pause_req_ex),
//  .pause_res_pc             (pause_res_pc),
//  .pause_res_if             (pause_res_if),
//  .pause_res_id             (pause_res_id),
//  .pause_res_ex             (pause_res_ex),
//  .pause_res_mem            (pause_res_mem),
//  .pause_res_wb             (pause_res_wb),
//  .abnormal_type            (mem_abnormal_type_out),
//  .cp0_epc_in               (mem_cp0_epc_in),
//  .interrupt_pc_out         (interrupt_pc_out),
//  .flush                    (flush)
//  );
//
//  cp0 u_cp0(
//    .clk                    (clk),
//    .rst                    (rst),
//    .we_in                  (wb_cp0_we_in),
//    .waddr_in               (wb_cp0_waddr_in),
//    .data_in                (wb_cp0_wdata_in),
//    .raddr_in               (ex_cp0_raddr_out),
//    .int_in                 (interrupt_in),
//    .data_out               (ex_cp0_data_in),
//    .count_out              (),
//    .compare_out            (),
//    .status_out             (mem_cp0_status_in),
//    .cause_out              (mem_cp0_cause_in),
//    .epc_out                (mem_cp0_epc_in),
//    .config_out             (),
//    .timer_int_o            (),
//    .abnormal_type          (mem_abnormal_type_out),
//    .current_pc_addr_in     (mem_current_pc_addr_out)
//  );

endmodule












