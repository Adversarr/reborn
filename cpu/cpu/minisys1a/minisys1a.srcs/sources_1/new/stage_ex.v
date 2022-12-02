// ex.v
// 2020-11 @ https://github.com/seu-cs-class2/minisys-1a-cpu

`include "public.v"

// ָ��ִ��ģ��
module ex (

  input rst,
  input wire[`ALUOpRange] aluop_in,
  input wire[`WordRange] data1_in,  // һ����rs
  input wire[`WordRange] data2_in,  // һ����rt
  input wire[`RegRangeLog2] wreg_addr_in,
  input wire wreg_e_in,

  output reg[`RegRangeLog2] wreg_addr_out,
  output reg wreg_e_out,
  output reg[`WordRange] wreg_data_out,

  input wire[`WordRange] hi_data_in,  // ����ָ�����׶Σ�hi�����Ľ��
  input wire[`WordRange] lo_data_in,  // lo�����Ľ��
  input wire mem_hilo_we_in, // Ŀǰ���ڷô�׶ε�hi,lo��дʹ�ܣ�������ָ�����һ��ָ�
  input wire[`WordRange] mem_hi_data_in,  // �ô�׶�д��hi��ֵ
  input wire[`WordRange] mem_lo_data_in,  // �ô�׶�д��lo��ֵ
  input wire wb_hilo_we_in,  // Ŀǰ����д�ؽ׶ε�hiloдʹ�ܣ�������ָ���������ָ�
  input wire[`WordRange] wb_hi_data_in,  // д�ؽ׶�д��hi��ֵ
  input wire[`WordRange] wb_lo_data_in,  // д�ؽ׶�д��lo��ֵ
  
  output reg hilo_we_out,  // ����ָ���Ƿ�Ҫдhilo
  output reg[`WordRange] hi_data_out,  // д���hi����
  output reg[`WordRange] lo_data_out,  // д���lo����

  output reg pause_req,

  input wire[`WordRange] link_addr_in, // ����ķ��ص�ַ

  output reg[`WordRange] div_data1_signed,  // �з��ų����ı�����
  output reg[`WordRange] div_data2_signed, // �з��ų����ĳ���
  output reg[`WordRange] div_data1_unsigned, // �޷��ų����ı�����
  output reg[`WordRange] div_data2_unsigned, // �޷��ų����ĳ���
  output reg div_data_valid_signed, // �з��ų��������Ƿ���Ч���Ƿ�ʼ������
  output reg div_data_valid_unsigned, // �޷��ų��������Ƿ���Ч
  input wire[`DivMulResultRange] div_result_signed,  // ���64λ
  input wire div_result_valid_signed,  // �з��ų�������Ƿ���Ч����Ч˵������������Ӧ�û�ȡ�����
  input wire[`DivMulResultRange] div_result_unsigned, // ���64λ
  input wire div_result_valid_unsigned, // �޷��ų�������Ƿ���Ч����Ч˵������������Ӧ�û�ȡ�����

  output reg[`WordRange] mul_data1,
  output reg[`WordRange] mul_data2,
  output reg mul_type,
  output reg mul_valid,
  input wire [`DivMulResultRange] mul_result,
  input wire mul_result_valid,




  input is_in_delayslot, // �������ӳٲ��źţ�������ִ�н׶ε�ָ���Ƿ����ӳٲ�ָ��

  input wire[`WordRange] ins_in, // ������ָ���źţ���id�׶�һֱ���ݹ���
  output reg[`ALUOpRange] aluop_out, // Ҫ��ô沿�ִ���aluop
  output reg[`WordRange] mem_addr_out, // Ҫ��ô沿�ִ��ݼ�������ڴ��ַ�����д洢���ָ������õ���
  output reg[`WordRange] mem_data_out, // Ҫ��ô沿�ִ���д���ڴ�����ݣ�storeָ��Ż��õ���

  //cp0���
  input wire[`WordRange] cp0_data_in,//��cp0��ȡ������  ֻ��������ͨ�üĴ�����
  output reg[4:0] cp0_raddr_out, //ֱ�Ӵ���cp0�ĵ�ַ

  input wire f_mem_cp0_we_in, //��ǰ���ڷô�׶ε�ָ���Ƿ�Ҫдcp0
  input wire[4:0] f_mem_cp0_w_addr, //Ҫд�ĵ�ַ
  input wire[`WordRange] f_mem_cp0_w_data, //Ҫд�������
  input wire f_wb_cp0_we_in,   //ͬ��  ��ǰ����д�ؽ׶ε�ָ���Ƿ�Ҫдcp0
  input wire[4:0] f_wb_cp0_w_addr, //д��ĵ�ַ
  input wire[`WordRange] f_wb_cp0_w_data,  //д�������

  output reg cp0_we_out,    //cp0�Ƿ�Ҫ��д����ǰָ�� ���´�����ˮ
  output reg[4:0] cp0_waddr_out,  //cp0д��ַ   ���´�����ˮ
  output reg[`WordRange] cp0_w_data_out,   //Ҫд��cp0������ ���´�����ˮ


  //�����ӵ�Ҫ���¼���ˮ��������
  output reg[`WordRange] ins_out,

  //�쳣���
  input wire[`WordRange] current_ex_pc_addr_in,
  input wire[`WordRange] abnormal_type_in,
  output reg[`WordRange] abnormal_type_out,
  output reg[`WordRange] current_ex_pc_addr_out
);

  wire[`WordRange] alu_res;  // alu�Ľ��
  reg[`WordRange] mov_res;  // ת��ָ����hi��lo���Ľ��
  
  reg[`WordRange] hi_temp;  // �ݴ�hi
  reg[`WordRange] lo_temp;  // �ݴ�lo


  wire signed [`WordRange] mul_signed_data1;
  wire signed [`WordRange] mul_signed_data2;
  assign mul_signed_data1 = data1_in;
  assign mul_signed_data2 = data2_in;

  alu u_alu (
  .data1      (data1_in),
  .data2      (data2_in),
  .op         (aluop_in),
  .res        (alu_res)
  );


  always @(*) begin
    if (rst == `Enable) begin
      wreg_e_out = `Disable;
      pause_req = `Disable;
      div_data_valid_signed = `Disable;
      div_data_valid_unsigned = `Disable;
      div_data1_signed = `ZeroWord;
      div_data2_signed = `ZeroWord;
      div_data1_unsigned = `ZeroWord;
      div_data2_unsigned = `ZeroWord;
      mem_addr_out = `ZeroWord;
      aluop_out = aluop_in;
      mem_data_out = `ZeroWord;
      wreg_data_out = `ZeroWord;
      abnormal_type_out = `ZeroWord;
      current_ex_pc_addr_out = `ZeroWord;
    end else begin
      ins_out = ins_in;
      wreg_e_out = wreg_e_in;
      wreg_addr_out = wreg_addr_in;
      pause_req = `Disable;
      div_data_valid_signed = `Disable;
      div_data_valid_unsigned = `Disable;
      div_data1_signed = `ZeroWord;
      div_data2_signed = `ZeroWord;
      div_data1_unsigned = `ZeroWord;
      div_data2_unsigned = `ZeroWord;
      mul_data1 = `ZeroWord;
      mul_data2 = `ZeroWord;
      mul_valid = `Disable;
      mem_addr_out = data1_in + {{16{ins_in[15]}}, ins_in[15:0]};  // �����������Ϊ���ô��ݵ��ź��٣�����ʱ���߼�������������ex���ֵĹ���
      aluop_out = aluop_in;
      mem_data_out = data2_in; // ������ʲô�洢����������ȥʹ��rt������
      wreg_data_out = alu_res;
      abnormal_type_out = abnormal_type_in;
      current_ex_pc_addr_out = current_ex_pc_addr_in;
      case (aluop_in)
        `ALUOP_DIV: begin
          if (div_result_valid_signed == `Disable) begin  // ������δ����
            div_data1_signed = data1_in;
            div_data2_signed = data2_in;
            div_data_valid_signed = `Enable;  // ������Ч
            pause_req = `Enable;  // ��ͣ��ˮ
          end else if (div_result_valid_signed == `Enable) begin  // ��������
            div_data1_signed = data1_in;
            div_data2_signed = data2_in;
            div_data_valid_signed = `Disable;  // ������Ч
            pause_req = `Disable;  // ������ˮ
          end
        end
        `ALUOP_DIVU: begin
          if (div_result_valid_unsigned == `Disable) begin
            div_data1_unsigned = data1_in;
            div_data2_unsigned = data2_in;
            div_data_valid_unsigned = `Enable;
            pause_req = `Enable;
          end else if (div_result_valid_unsigned == `Enable) begin
            div_data1_unsigned = data1_in;
            div_data2_unsigned = data2_in;
            div_data_valid_unsigned = `Disable;
            pause_req = `Disable;
          end
        end
        `ALUOP_MULT:begin
          if(mul_result_valid == `Disable)begin
            mul_data1 = data1_in;
            mul_data2 = data2_in;
            mul_type = `Enable;
            mul_valid = `Enable;
            pause_req = `Enable;
          end else begin
            mul_data1 = data1_in;
            mul_data2 = data2_in;
            mul_valid = `Disable;
            pause_req = `Disable;
          end
        end
        `ALUOP_MULTU:begin
          if(mul_result_valid == `Disable)begin
            mul_data1 = data1_in;
            mul_data2 = data2_in;
            mul_type = `Disable;
            mul_valid = `Enable;
            pause_req = `Enable;
          end else begin
            mul_data1 = data1_in;
            mul_data2 = data2_in;
            mul_valid = `Disable;
            pause_req = `Disable;
          end
        end
        `EXOP_JR,
        `EXOP_JALR,
        `EXOP_J,
        `EXOP_JAL,
        `EXOP_BEQ,
        `EXOP_BGTZ,
        `EXOP_BLEZ,
        `EXOP_BNE,
        `EXOP_BGEZ,
        `EXOP_BGEZAL,
        `EXOP_BLTZ,
        `EXOP_BLTZAL: begin
          wreg_data_out = link_addr_in;
        end
        `EXOP_MFC0,
        `EXOP_MFLO,
        `EXOP_MFHI:begin
          wreg_data_out = mov_res;
        end
      endcase
    end
  end

  always @(*) begin
    if (rst == `Enable) begin
      hi_temp = `ZeroWord;
      lo_temp = `ZeroWord;
    // ���MEM-EX��ˮ��ͻ
    end else if (mem_hilo_we_in == `Enable) begin  // �����һ��ָ��Ҳ��дhilo
      hi_temp = mem_hi_data_in;
      lo_temp = mem_lo_data_in;
    // ���WB-EX��ˮ��ͻ
    end else if (wb_hilo_we_in == `Enable) begin  // ���������ָ��Ҳ��дhilo
      hi_temp = wb_hi_data_in;
      lo_temp = wb_lo_data_in;  
    end else begin
      hi_temp = hi_data_in;
      lo_temp = lo_data_in;
    end
  end

  always @(*) begin
    if (rst == `Enable) begin
      mov_res = `ZeroWord;
    end else begin
      case (aluop_in)
        `EXOP_MFHI: begin
          mov_res = hi_temp;
        end
        `EXOP_MFLO: begin
          mov_res = lo_temp;
        end
        `EXOP_MFC0: begin //Ҫд��cp0�Ĵ������ÿ�һ�������ǲ������µ�
          cp0_raddr_out = ins_in[15:11];
          mov_res = cp0_data_in;
          if(f_mem_cp0_we_in == `Enable && f_mem_cp0_w_addr == ins_in[15:11])begin
            mov_res = f_mem_cp0_w_data;
          end else if(f_wb_cp0_we_in == `Enable && f_wb_cp0_w_addr == ins_in[15:11]) begin
            mov_res = f_wb_cp0_w_data;
          end
        end
      endcase
    end
  end

  always @(*) begin
    if (rst == `Enable) begin
      hilo_we_out = `Disable;
      hi_data_out = `ZeroWord;
      lo_data_out = `ZeroWord;
    end else begin
      case (aluop_in)
       `ALUOP_DIV: begin
         hilo_we_out = `Enable;
         hi_data_out = div_result_signed[31:0];  // HI��������LO����
         lo_data_out = div_result_signed[63:32];
       end
       `ALUOP_DIVU: begin
         hilo_we_out = `Enable;
         hi_data_out = div_result_unsigned[31:0];
         lo_data_out = div_result_unsigned[63:32];
       end
       `ALUOP_MULT:begin
         hilo_we_out = `Enable;
         hi_data_out = mul_result[63:32];
         lo_data_out = mul_result[31:0];
       end
       `ALUOP_MULTU:begin
         hilo_we_out = `Enable;
         hi_data_out = mul_result[63:32];
         lo_data_out = mul_result[31:0];
       end
       `EXOP_MTHI: begin
          hilo_we_out = `Enable;
          hi_data_out = data1_in;
          lo_data_out = lo_data_in;
       end
       `EXOP_MTLO: begin
          hilo_we_out = `Enable;
          hi_data_out = hi_data_in;
          lo_data_out = data1_in;
       end
      endcase
    end
  end

  always @(*) begin
    if(rst == `Enable)begin
      cp0_we_out = `Disable;
      cp0_waddr_out = 5'b00000;
      cp0_w_data_out = `ZeroWord;
    end else if(aluop_in == `EXOP_MTC0) begin
      cp0_we_out = `Enable;
      cp0_waddr_out = ins_in[15:11];
      cp0_w_data_out = data1_in;
    end else begin
      cp0_we_out = `Disable;
      cp0_waddr_out = 5'b00000;
      cp0_w_data_out = `ZeroWord;
    end
  end

endmodule
