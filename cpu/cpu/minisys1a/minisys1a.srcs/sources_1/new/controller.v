// ppl_scheduler.v
// 2020-11 @ https://github.com/seu-cs-class2/minisys-1a-cpu

`include "public.v"

// ��ˮ�ߵ�����
module ppl_scheduler (

  input rst,

  // ��������
  input pause_req_id,
  input pause_req_ex,

  // ������Ӧ
  output reg pause_res_pc,
  output reg pause_res_if,
  output reg pause_res_id,
  output reg pause_res_ex,
  output reg pause_res_mem,
  output reg pause_res_wb, 

  // �쳣���
  input wire[`WordRange] abnormal_type,
  input wire[`WordRange] cp0_epc_in,
  output reg[`WordRange] interrupt_pc_out,
  output reg flush

);

  always @(*) begin
    if (rst == `Enable) begin
      // rstʱ����������ͣ
      pause_res_pc = `Disable;
      pause_res_if = `Disable;
      pause_res_id = `Disable;
      pause_res_ex = `Disable;
      pause_res_mem = `Disable;
      pause_res_wb = `Disable;
      flush = `Disable;
    end else if(abnormal_type != `ZeroWord) begin 
      flush = `Enable;
      pause_res_pc = `Disable;
      pause_res_if = `Disable;
      pause_res_id = `Disable;
      pause_res_ex = `Disable;
      pause_res_mem = `Disable;
      pause_res_wb = `Disable;
      case (abnormal_type[6:2])
        `ABN_INTERRUPT,
        `ABN_BREAK,
        `ABN_OVERFLOW,
        `ABN_PRESERVE,
        `ABN_SYSTEMCALL,
        5'b00000: begin
          interrupt_pc_out = 32'h0000F000;
        end 
        `ABN_ERET: begin
          interrupt_pc_out = cp0_epc_in;
        end
        default: begin
        end
      endcase
    end else if (pause_req_id == `Enable || pause_req_ex == `Enable) begin
      // ������ͣ����ʱ����ͣ������ˮ��
      flush = `Disable;
      pause_res_pc = `Enable;
      pause_res_if = `Enable;
      pause_res_id = `Enable;
      pause_res_ex = `Enable;
      pause_res_mem = `Enable;
      pause_res_wb = `Enable;
    end else begin
      // Ĭ�ϲ���ͣ
      flush = `Disable;
      pause_res_pc = `Disable;
      pause_res_if = `Disable;
      pause_res_id = `Disable;
      pause_res_ex = `Disable;
      pause_res_mem = `Disable;
      pause_res_wb = `Disable;
    end
  end

endmodule 