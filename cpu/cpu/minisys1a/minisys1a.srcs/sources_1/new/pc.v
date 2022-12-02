// pc.v
// 2020-11 @ https://github.com/seu-cs-class2/minisys-1a-cpu

`include "public.v"

// ָ�������PC
module pc (

  input clk, // ʱ��
  input rst, // ͬ����λ�ź�
  output reg[`WordRange] pc, // ��ǰPC
  
  input wire pause, // ��ˮ��ͣ�ź�

  input wire branch_en_in, // �Ƿ�ת��
  input wire[`WordRange] branch_addr_in, // ת�Ƶĵ�ַ

  //�쳣���
  input wire flush,
  input wire[`WordRange] interrupt_pc

);

  // ���rst����λ��0x0������+4
  always @(posedge clk) begin
    if (rst == `Enable) begin
      pc = `ZeroWord;
    end else if(flush == `Enable) begin
      //�����쳣����pcȡ��ڵ�ַ
      pc = interrupt_pc;
    end else if (pause == `Enable) begin
      // ��ˮ��ͣʱ����PC����
      pc = pc;
    end else if (branch_en_in == `Enable) begin  // ���Ҫת�ƣ���PCֱ�Ӹ�ֵΪת�Ƶ�ַ
      pc = branch_addr_in;
    end else begin
      pc = pc + 32'd4;
    end
  end

endmodule
