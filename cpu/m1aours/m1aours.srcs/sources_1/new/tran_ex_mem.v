`include "public.v"

module tran_ex_mem(  
  input rst,
  input clk,

  input wire ex_write_reg_enable,
  input wire[`RegRangeLog2] ex_write_reg_addr,
  input wire[`WordRange] ex_write_reg_data,

  output reg mem_write_reg_enable,
  output reg[`RegRangeLog2] mem_write_reg_addr,
  output reg[`WordRange] mem_write_reg_data,

  input wire ex_hilo_write_enable,
  input wire[`WordRange] ex_hi_data,
  input wire[`WordRange] ex_lo_data,
  
  output reg mem_hilo_write_enable,
  output reg[`WordRange] mem_hi_data,
  output reg[`WordRange] mem_lo_data,

  input wire pause,
  input wire[`ALUOpRange] ex_aluop,
  input wire[`WordRange] ex_mem_addr,
  input wire[`WordRange] ex_mem_data,
  output reg[`ALUOpRange] mem_aluop,
  output reg[`WordRange] mem_addr,
  output reg[`WordRange] mem_data,


  //Instruction
  input wire[`WordRange] ex_ins,
  output reg[`WordRange] mem_ins,

  //cp0
  input wire ex_cp0_we,
  input wire[4:0] ex_cp0_waddr,
  input wire[`WordRange] ex_cp0_wdata,
  output reg mem_cp0_we,
  output reg[4:0] mem_cp0_waddr,
  output reg[`WordRange] mem_cp0_wdata,

  //“Ï≥£œ‡πÿ
  input wire flush,
  input wire[`WordRange] ex_pc_addr_in,
  input wire[`WordRange] ex_abnormal_type,
  output reg[`WordRange] mem_pc_addr_out,
  output reg[`WordRange] mem_abnormal_type
);


  always @(posedge clk) begin
    if (rst == `Enable) begin
      mem_write_reg_enable = `Disable;
      mem_write_reg_data = `ZeroWord;
      mem_hilo_write_enable = `Disable;
      mem_hi_data = `ZeroWord;
      mem_lo_data = `ZeroWord;
      mem_aluop = 6'b000000;
      mem_addr = `ZeroWord;
      mem_data = `ZeroWord;
      mem_ins = `ZeroWord;
      mem_cp0_we = `Disable;
      mem_cp0_waddr = 5'b00000;
      mem_cp0_wdata = `ZeroWord;
      mem_pc_addr_out = `ZeroWord;
      mem_abnormal_type = `ZeroWord;
    end else if (flush == `Enable) begin
      mem_write_reg_enable = `Disable;
      mem_write_reg_data = `ZeroWord;
      mem_hilo_write_enable = `Disable;
      mem_hi_data = `ZeroWord;
      mem_lo_data = `ZeroWord;
      mem_aluop = 6'b000000;
      mem_addr = `ZeroWord;
      mem_data = `ZeroWord;
      mem_ins = `ZeroWord;
      mem_cp0_we = `Disable;
      mem_cp0_waddr = 5'b00000;
      mem_cp0_wdata = `ZeroWord;
      mem_pc_addr_out = `ZeroWord;
      mem_abnormal_type = `ZeroWord;
    end else if (pause == `Enable)begin
      mem_write_reg_enable = mem_write_reg_enable;
      mem_write_reg_addr = mem_write_reg_addr;
      mem_write_reg_data = mem_write_reg_data;
      mem_hilo_write_enable = mem_hilo_write_enable;
      mem_hi_data = mem_hi_data;
      mem_lo_data = mem_lo_data;
      mem_addr = mem_addr;
      mem_data = mem_data;
      mem_aluop = mem_aluop;
      mem_ins = mem_ins;
      mem_cp0_we = mem_cp0_we;
      mem_cp0_waddr = mem_cp0_waddr;
      mem_cp0_wdata = mem_cp0_wdata;
      mem_pc_addr_out = mem_pc_addr_out;
      mem_abnormal_type = mem_abnormal_type;
    end else begin
      mem_write_reg_enable = ex_write_reg_enable;
      mem_write_reg_addr = ex_write_reg_addr;
      mem_write_reg_data = ex_write_reg_data;
      mem_hilo_write_enable = ex_hilo_write_enable;
      mem_hi_data = ex_hi_data;
      mem_lo_data = ex_lo_data;
      mem_addr = ex_mem_addr;
      mem_data = ex_mem_data;
      mem_aluop = ex_aluop;
      mem_ins = ex_ins;
      mem_cp0_we = ex_cp0_we;
      mem_cp0_waddr = ex_cp0_waddr;
      mem_cp0_wdata = ex_cp0_wdata; 
      mem_pc_addr_out = ex_pc_addr_in;
      mem_abnormal_type = ex_abnormal_type;
    end
  end
endmodule
