`include "public.v"

module stage_mem(
  input clk,
  input rst,
  input wire write_reg_enable_in,
  input wire[`WordRange] write_reg_data_in,
  input wire[`RegRangeLog2] write_reg_addr_in,

  output reg write_reg_enable_out,
  output reg[`WordRange] write_reg_data_out,
  output reg[`RegRangeLog2] write_reg_addr_out,

  input wire hilo_we_in,
  input wire[`WordRange] hi_data_in,
  input wire[`WordRange] lo_data_in,
  
  output reg hilo_we_out,
  output reg[`WordRange] hi_data_out,
  output reg[`WordRange] lo_data_out,

  input wire[`ALUOpRange] aluop_in, //���ϼ���ˮ����aluop
  input wire[`WordRange] mem_addr_in,  //���ϼ���ˮ���Ĵ洢����ַ
  input wire[`WordRange] mem_store_data_in,  //���ϼ���ˮ����Ҫ����洢��������

  input wire[`WordRange] mem_read_data_in,   //�Ӵ洢�����Ķ���������
 
  output reg[`WordRange] mem_addr_out,  //������ַ���ߵĵ�ַ
  output reg mem_we_out,   //�����������ߵ�дʹ��
  output reg[3:0] mem_byte_sel_out,   //�����������ߵı���ʹ��
  output wire[`WordRange] mem_store_data_out,   //����д�������ߵ�����
  output reg mem_enable_out,  //�����������ߵ���ʹ�� ������ûʲô�ã�����������

  //cp0���
  input wire cp0_write_enable_in,
  input wire[4:0] cp0_write_addr_in,
  input wire[`WordRange] cp0_write_data_in,
  output reg cp0_write_enable_out,
  output reg[4:0] cp0_write_addr_out,
  output reg[`WordRange] cp0_write_data_out,

  //�쳣�������
  input wire[`WordRange] current_mem_pc_addr_in,
  input wire[`WordRange] abnormal_type_in,
  input wire[`WordRange] cp0_status_in,
  input wire[`WordRange] cp0_cause_in,
  input wire[`WordRange] cp0_epc_in,
  //�˴�Ҫ��Ҫ���дcp0�Ĵ�����ɵ�������أ� �о�����Ҫ ��Ϊcp0��������ȥд ���Ҷ����������Ĵ���Ҳ��Ӧ��ȥд
  output reg[`WordRange] abnormal_type_out,
  output reg[`WordRange] current_mem_pc_addr_out

);

  assign mem_store_data_out = mem_store_data_in;
  //���ж��쳣
  always @(*) begin
    if(rst == `Enable) begin
      abnormal_type_out = `ZeroWord;
    end else begin
      if(current_mem_pc_addr_in != `ZeroWord) begin //�����0ָ��͸��������쳣�����
        if(cp0_status_in[0] == `Enable)begin  //����������жϺ��쳣�����û���쳣
          //����ֱ�Ӱ��ϼ����������쳣�������
          abnormal_type_out = {16'h0000, cp0_cause_in[13:8], 1'b0, abnormal_type_in[6:2], 2'b00};  
          current_mem_pc_addr_out = current_mem_pc_addr_in;
        end else begin
          if(abnormal_type_in[6:2] == `ABN_ERET)begin //�������ж�ʱ�����������ERET����Ҫ�����쳣��cp0��ppl
            abnormal_type_out = {16'h0000, cp0_cause_in[13:8], 1'b0, abnormal_type_in[6:2], 2'b00};
          end else begin
            abnormal_type_out = `ZeroWord;
          end      
        end 
      end else begin
        abnormal_type_out = `ZeroWord;
      end
    end
  end

  always @(*) begin
    if (rst == `Enable) begin
      write_reg_enable_out = `Disable;
      write_reg_data_out = `ZeroWord;
      hilo_we_out = `Disable;
      hi_data_out = `ZeroWord;
      lo_data_out = `ZeroWord;
      mem_addr_out = `ZeroWord;
      mem_we_out = `Disable;
      mem_byte_sel_out = 4'b0000;
      mem_enable_out = `Disable;
      cp0_write_enable_out = `Disable;
      cp0_write_addr_out = 5'b00000;
      cp0_write_data_out = `ZeroWord;
    end else begin
      write_reg_enable_out = write_reg_enable_in;
      write_reg_data_out = write_reg_data_in;
      write_reg_addr_out = write_reg_addr_in;
      hilo_we_out = hilo_we_in;
      hi_data_out = hi_data_in;
      lo_data_out = lo_data_in;
      mem_addr_out = `ZeroWord;
      mem_we_out = `Disable;
      mem_byte_sel_out = 4'b1111;
      mem_enable_out = `Disable;
      cp0_write_enable_out = cp0_write_enable_in;
      cp0_write_addr_out = cp0_write_addr_in;
      cp0_write_data_out = cp0_write_data_in;
      case (aluop_in)
        `EXOP_LB: begin
          mem_addr_out = mem_addr_in;
          mem_we_out = `Disable;
          mem_enable_out = `Enable;  //Fix me���˴��Ժ�϶�Ҫ�޸ģ���Ϊ�����ϵĴ洢����256*16bits�ģ�Ϊ�����㰴�ֽڱ�ַ��������С�˴洢
          case (mem_addr_in[1:0])  // �˴����߼�������Ҫ�ı䣡
            2'b00: begin
              write_reg_data_out = {{24{mem_read_data_in[7]}},mem_read_data_in[7:0]};  //������չ
              mem_byte_sel_out = 4'b0001; //С�˴洢  ȡ�ĸ��ֽڵ����λ��Ϊ��ַ���λ
            end
            2'b01: begin
              write_reg_data_out = {{24{mem_read_data_in[15]}},mem_read_data_in[15:8]};
              mem_byte_sel_out = 4'b0010;
            end
            2'b10: begin
              write_reg_data_out = {{24{mem_read_data_in[23]}},mem_read_data_in[23:16]};
              mem_byte_sel_out = 4'b0100;
            end
            2'b11: begin
              write_reg_data_out = {{24{mem_read_data_in[31]}},mem_read_data_in[31:24]};
              mem_byte_sel_out = 4'b1000;
            end
          endcase
        end
        `EXOP_LBU:begin
          mem_addr_out = mem_addr_in;
          mem_we_out = `Disable;
          mem_enable_out = `Enable;  //Fix me���˴��Ժ�϶�Ҫ�޸ģ���Ϊ�����ϵĴ洢����256*16bits�ģ�Ϊ�����㰴�ֽڱ�ַ��������С�˴洢
          case (mem_addr_in[1:0])  // �˴����߼�������Ҫ�ı䣡
            2'b00: begin
              write_reg_data_out = {{24{1'b0}},mem_read_data_in[7:0]};  //����չ
              mem_byte_sel_out = 4'b0001; //С�˴洢  ȡ�ĸ��ֽڵ����λ��Ϊ��ַ���λ
            end
            2'b01: begin
              write_reg_data_out = {{24{1'b0}},mem_read_data_in[15:8]};
              mem_byte_sel_out = 4'b0010;
            end
            2'b10: begin
              write_reg_data_out = {{24{1'b0}},mem_read_data_in[23:16]};
              mem_byte_sel_out = 4'b0100;
            end
            2'b11: begin
              write_reg_data_out = {{24{1'b0}},mem_read_data_in[31:24]};
              mem_byte_sel_out = 4'b1000;
            end
          endcase
        end
        `EXOP_LH:begin
          mem_addr_out = mem_addr_in;
          mem_we_out = `Disable;
          mem_enable_out = `Enable;
          case (mem_addr_in[1:0])
            2'b00,
            2'b01:begin
              write_reg_data_out = {{16{mem_read_data_in[15]}},mem_read_data_in[15:0]};
              mem_byte_sel_out = 4'b0011;  //С�˴洢 ���������� �о����ϵĴ�˴洢�Ǵ����
            end
            2'b10,
            2'b11:begin
              write_reg_data_out = {{16{mem_read_data_in[31]}},mem_read_data_in[31:16]};
              mem_byte_sel_out = 4'b1100;
            end
          endcase
        end
        `EXOP_LHU:begin
          mem_addr_out = mem_addr_in;
          mem_we_out = `Disable;
          mem_enable_out = `Enable;
          case (mem_addr_in[1:0])
            2'b00,
            2'b01:begin
              write_reg_data_out = {{16{1'b0}},mem_read_data_in[15:0]};
              mem_byte_sel_out = 4'b0011;  //С�˴洢 ���������� �о����ϵĴ�˴洢�Ǵ����
            end
            2'b10,
            2'b11:begin
              write_reg_data_out = {{16{1'b0}},mem_read_data_in[31:16]};
              mem_byte_sel_out = 4'b1100;
            end
          endcase
        end
        `EXOP_SB:begin
          mem_addr_out = mem_addr_in;
          mem_we_out = `Enable;
          mem_enable_out = `Enable;
          case (mem_addr_in[1:0])
            2'b00:begin
              mem_byte_sel_out = 4'b0001;
            end
            2'b01:begin
              mem_byte_sel_out = 4'b0010;
            end
            2'b10:begin
              mem_byte_sel_out = 4'b0100;
            end
            2'b11:begin
              mem_byte_sel_out = 4'b1000;
            end
          endcase
        end
        `EXOP_SH:begin
          mem_addr_out = mem_addr_in;
          mem_we_out = `Enable;
          mem_enable_out = `Enable;
          case (mem_addr_in[1:0])
            2'b00,
            2'b01:begin
              mem_byte_sel_out = 4'b0011;
            end
            2'b10,
            2'b11:begin
              mem_byte_sel_out = 4'b1100;
            end
          endcase
        end
        `EXOP_LW:begin
          mem_addr_out = mem_addr_in;
          mem_we_out = `Disable;
          mem_enable_out = `Enable;
          write_reg_data_out = mem_read_data_in;
          mem_byte_sel_out = 4'b1111;
        end
        `EXOP_SW:begin
          mem_addr_out = mem_addr_in;
          mem_we_out = `Enable;
          mem_enable_out = `Enable;
          mem_byte_sel_out = 4'b1111;
        end
      endcase
    end
  end
endmodule

