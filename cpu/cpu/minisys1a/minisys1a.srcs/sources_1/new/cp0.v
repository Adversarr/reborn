// cp0.v
// 2020-11 @ https://github.com/seu-cs-class2/minisys-1a-cpu

`include "public.v"

// Э������CP0
// �ڲ��Ĵ�����ο����佲��P93
module cp0 (
  input clk,
  input rst,
  input wire we_in,  //дʹ��
  input wire[4:0] waddr_in,  //д�ļĴ�����ַ
  input wire[`WordRange] data_in,   //д������
  input wire[4:0] raddr_in,  //���ĵ�ַ
  input wire[5:0] int_in, //�����ж�
  output reg[`WordRange] data_out,
  output reg[`WordRange] count_out, // Count�Ĵ��������ڶ�ʱ�жϵĲ���
  output reg[`WordRange] compare_out, // Compare�Ĵ��������countʵ�ֶ�ʱ�ж�
  // Status�Ĵ���������ж�������Ϣ��
  // �ɶ�   ��д
  // 31..16   15..8   7..1      0
  // Reserved IntMask Reserved  0
  // *** IntMask
  //     1..0: priority ctrl
  //     7..2: 6 mask bits
  output reg[`WordRange] status_out, 
  // Cause�Ĵ������洢�쳣���ж�Դ����Ϣ����¼���һ���쳣ԭ��
  // 31..14   13..8   7  6..2    1..0
  // Reserved IntPend 0  ExcCode 00
  // *** ExcCode
  //     00000: ext int
  //     01000: syscall
  //     01001: break
  //     01010: not implemented
  //     01100: ovf
  output reg[`WordRange] cause_out,
  // EPC�Ĵ������쳣���жϵķ��ص�ַ�Ĵ���
  // 31..0
  // IRetAddr
  output reg[`WordRange] epc_out,
  output reg[`WordRange] config_out,
  output reg timer_int_o,
  //�쳣����ʱ���ӵĽӿ�
  input wire[`WordRange] abnormal_type,
  input wire[`WordRange] current_pc_addr_in
);

  always @(posedge clk)begin
    if(rst == `Enable)begin
      data_out <= `ZeroWord;
      count_out <= `ZeroWord;
      compare_out <= `ZeroWord;
      status_out <= 32'd1;
      cause_out <= `ZeroWord;
      epc_out <= `ZeroWord;
      config_out <= `ZeroWord;
      timer_int_o <= `Disable;
    end else begin
      count_out <= count_out + 32'd1;
      cause_out[13:8] <= int_in; //cause��8-13λ��ʾ�ⲿ�жϵ����
      if(compare_out != `ZeroWord && count_out == compare_out) begin
        timer_int_o <= `Enable;
      end
  
      //�����쳣
      if(abnormal_type != `ZeroWord)begin
        epc_out <= current_pc_addr_in;
        status_out[0] <= `Disable; //�ر��ն�
        cause_out[6:2] <= abnormal_type[6:2];
        if(abnormal_type[6:2] == `ABN_ERET)begin
          epc_out <= `ZeroWord;
          status_out[0] <= `Enable; //���ж�
        end
      end
  
  
      if(we_in == `Enable)begin
        case (waddr_in)
          `CP0_REG_COUNT: begin
            count_out <= data_in;
          end  
          `CP0_REG_COMPARE: begin
            compare_out <= data_in;
            timer_int_o <= `Disable;
          end
          `CP0_REG_STATUE:begin
            status_out <= data_in;
          end
          `CP0_REG_EPC:begin
            epc_out <= data_in;
          end
          `CP0_REG_CAUSE:begin
            cause_out[6:2] = data_in[6:2];
          end
          default: begin
          end
        endcase
      end
      // DataOut
      case (raddr_in)
        `CP0_REG_COUNT: begin
          data_out = count_out;
        end  
        `CP0_REG_COMPARE: begin
          data_out = compare_out;
        end
        `CP0_REG_STATUE:begin
          data_out = status_out;
        end
        `CP0_REG_EPC:begin
          data_out = epc_out;
        end
        `CP0_REG_CAUSE:begin
          data_out = cause_out;
        end
        default: begin end
      endcase
    end
  end

//  always @(*) begin //��ʱ��
//    if(rst == `Enable)begin
//      data_out = `ZeroWord;
//    end else begin
//      case (raddr_in)
//        `CP0_REG_COUNT: begin
//          data_out = count_out;
//        end  
//        `CP0_REG_COMPARE: begin
//          data_out = compare_out;
//        end
//        `CP0_REG_STATUE:begin
//          data_out = status_out;
//        end
//        `CP0_REG_EPC:begin
//          data_out = epc_out;
//        end
//        `CP0_REG_CAUSE:begin
//          data_out = cause_out;
//        end
//        default: begin
//        end
//      endcase
//    end
//  end
endmodule
