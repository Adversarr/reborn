// mem_wb.v
// 2020-11 @ https://github.com/seu-cs-class2/minisys-1a-cpu

`include "public.v"

// ��ˮ��MEM-WB֮��ļĴ���
// TODO: Ŀǰ��д��ֱͨ��
module mem_wb (

  input rst, // ����
  input clk, // ʱ��

  input wire mem_wreg_e, // �Ĵ�����дʹ��
  input wire[`RegRangeLog2] mem_wreg_addr, // �Ĵ�����д��ַ
  input wire[`WordRange] mem_wreg_data, // �Ĵ�����д����

  output reg wb_wreg_e, // �Ĵ�����дʹ��
  output reg[`RegRangeLog2] wb_wreg_addr, // �Ĵ�����д��ַ
  output reg[`WordRange] wb_wreg_data, // �Ĵ�����д����

  input wire mem_hilo_we,
  input wire[`WordRange] mem_hi_data,
  input wire[`WordRange] mem_lo_data,

  output reg wb_hilo_we,
  output reg[`WordRange] wb_hi_data,
  output reg[`WordRange] wb_lo_data,

  input wire pause,

  //cp0���
  input wire f_mem_cp0_we,
  input wire[4:0] f_mem_cp0_waddr,
  input wire[`WordRange] f_mem_cp0_wdata,
  output reg t_wb_cp0_we,
  output reg[4:0] t_wb_cp0_waddr,
  output reg[`WordRange] t_wb_cp0_wdata,

  //�쳣���
  input wire flush
);

  
  always @(posedge clk) begin
    // ����ʱ��disbale��0x0
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
