// mem_wb.v
// 2020-11 @ https://github.com/seu-cs-class2/minisys-1a-cpu

`include "public.v"

// 流水级MEM-WB之间的寄存器
// TODO: 目前先写成直通的
module mem_wb (

  input rst, // 重置
  input clk, // 时钟

  input wire mem_wreg_e, // 寄存器组写使能
  input wire[`RegRangeLog2] mem_wreg_addr, // 寄存器组写地址
  input wire[`WordRange] mem_wreg_data, // 寄存器组写数据

  output reg wb_wreg_e, // 寄存器组写使能
  output reg[`RegRangeLog2] wb_wreg_addr, // 寄存器组写地址
  output reg[`WordRange] wb_wreg_data, // 寄存器组写数据

  input wire mem_hilo_we,
  input wire[`WordRange] mem_hi_data,
  input wire[`WordRange] mem_lo_data,

  output reg wb_hilo_we,
  output reg[`WordRange] wb_hi_data,
  output reg[`WordRange] wb_lo_data,

  input wire pause,

  //cp0相关
  input wire f_mem_cp0_we,
  input wire[4:0] f_mem_cp0_waddr,
  input wire[`WordRange] f_mem_cp0_wdata,
  output reg t_wb_cp0_we,
  output reg[4:0] t_wb_cp0_waddr,
  output reg[`WordRange] t_wb_cp0_wdata,

  //异常相关
  input wire flush
);

  
  always @(posedge clk) begin
    // 重置时送disbale、0x0
    if (rst == `Enable) begin
      wb_wreg_e = `Disable;
      wb_wreg_data = `ZeroWord;
      wb_hilo_we = `Disable;
      wb_wreg_addr = 5'b00000;
      wb_hi_data = `ZeroWord;
      wb_lo_data = `ZeroWord;
      t_wb_cp0_we = `Disable;
      t_wb_cp0_waddr = 5'b00000;
      t_wb_cp0_wdata = `ZeroWord;
    end else if(flush == `Enable) begin
      wb_wreg_e = `Disable;
      wb_wreg_data = `ZeroWord;
      wb_hilo_we = `Disable;
      wb_wreg_addr = 5'b00000;
      wb_hi_data = `ZeroWord;
      wb_lo_data = `ZeroWord;
      t_wb_cp0_we = `Disable;
      t_wb_cp0_waddr = 5'b00000;
      t_wb_cp0_wdata = `ZeroWord;
    end else if(pause == `Enable) begin
      wb_wreg_e = wb_wreg_e;
      wb_wreg_addr = wb_wreg_addr;
      wb_wreg_data = wb_wreg_data;
      wb_hilo_we = wb_hilo_we;
      wb_hi_data = wb_hi_data;
      wb_lo_data = wb_lo_data;
      t_wb_cp0_we = t_wb_cp0_we;
      t_wb_cp0_waddr = t_wb_cp0_waddr;
      t_wb_cp0_wdata = t_wb_cp0_wdata;
    end else begin
      wb_wreg_e = mem_wreg_e;
      wb_wreg_addr = mem_wreg_addr;
      wb_wreg_data = mem_wreg_data;
      wb_hilo_we = mem_hilo_we;
      wb_hi_data = mem_hi_data;
      wb_lo_data = mem_lo_data;
      t_wb_cp0_we = f_mem_cp0_we;
      t_wb_cp0_waddr = f_mem_cp0_waddr;
      t_wb_cp0_wdata = f_mem_cp0_wdata;
    end
  end
endmodule