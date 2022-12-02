// id.v
// 2020-11 @ https://github.com/seu-cs-class2/minisys-1a-cpu

`include "public.v"

// ָ������ģ��
// ��ָ��������룬���������
// Դ������1��Դ������2��д���Ŀ�ļĴ������������ͣ��߼�����λ��������
module id (

  input rst, // ��λ
  input wire[`WordRange] pc_in, // �����PCֵ������׶�ָ���ַ
  input wire[`WordRange] ins_in, // �����ָ���ȡ����ָ��

  // �Ĵ�������������ؽӿ�
  input wire[`WordRange] reg1_data_in, // ����ļĴ�������1
  input wire[`WordRange] reg2_data_in, // ����ļĴ�������2
  output reg reg1_ren_out, // �Ĵ�����ʹ��1
  output reg reg2_ren_out, // �Ĵ�����ʹ��2
  output reg[`RegRangeLog2] reg1_addr_out, // �Ĵ�������ַ1
  output reg[`RegRangeLog2] reg2_addr_out, // �Ĵ�������ַ2

  // ����ִ�е�ԪӦִ�к��ֲ���
  output reg[`ALUOpRange] exop_out, // �����ALUOp

  // ���վ���������
  output reg[`WordRange] data1_out, // ���������1
  output reg[`WordRange] data2_out, // ���������2
  
  // �Ĵ���ȥ����ؽӿ�
  output reg wreg_wen_out, // д�Ĵ���ʹ�����
  output reg[`RegRangeLog2] wreg_addr_out, // д�Ĵ�����ַ���

  // ���沿�����ڲ�������ǰ�ƣ�ת�ƣ���������0����ID-EX�������1����ID-MEM���׶ε�RAW�������
  // EX�׶���������������ָ�
  input wire ex_wreg_en_in,
  input wire[`WordRange] ex_wreg_data_in,
  input wire[`RegRangeLog2] ex_wreg_addr_in,
  // MEM�׶���������������ָ�
  input wire mem_wreg_en_in,
  input wire[`WordRange] mem_wreg_data_in,
  input wire[`RegRangeLog2] mem_wreg_addr_in,

  output reg pause_req, // Ҫ�������ˮ��ͣ�ź�

  // �ӳٲ����
  input wire in_delayslot_in, // ��ǰҪ���루����׶Σ�ָ���Ƿ����ӳٲ���ָ�����ִ�У�
  output reg in_delayslot_out,  // ��ǰҪ��������׶Σ�ָ���Ƿ����ӳٲ���ָ�����ִ�У�
  output reg next_in_delayslot_out, // ����ָ���Ƿ����ӳٲ���ָ�����ǰָ���Ƿ�Ҫ��ת��
  
  // ��֧���
  output reg branch_en_out,  // ��֧��Ч�ź�
  output reg[`WordRange] branch_addr_out, // ��֧��ת��ַ
  output reg[`WordRange] link_addr_out, // ת��ָ����Ҫ����ĵ�ַ
  
  output reg[`WordRange] ins_out,   // ����ˮ�ߺ������ݵ�ָ�� ����Ӵ洢ָ��ʱ��Ҫ�õ�

  // �쳣���
  // abnormal_type_out
  // 31...12 Ԥ��
  // 11 eret
  // 10 systemcall
  // 9...8 abnormal info
  // 7...0 interrupt info
  output reg[`WordRange] abnormal_type_out,//ָ����쳣��Ϣ
  output reg[`WordRange] current_id_pc_addr_out //��ǰ��������׶�ָ��ĵ�ַ

);

  // ָ��ĸ����������
  wire[5:0] op = ins_in[`OpRange];
  wire[4:0] rs = ins_in[`RsRange];
  wire[4:0] rt = ins_in[`RtRange];
  wire[4:0] rd = ins_in[`RdRange];
  wire[4:0] shamt = ins_in[`ShamtRange];
  wire[5:0] func = ins_in[`FuncRange];
  wire[15:0] immediate = ins_in[`ImmedRange];
  wire[15:0] offset = ins_in[`OffsetRange];
  wire[25:0] address = ins_in[`AddressRange];

  reg[`WordRange] immed; // ָ���е�����������չ���
  initial begin
    pause_req = `Disable;
  end

  // ָ������
  always @(*) begin
    // rstʱ�ص�����ʹ�ܣ����������
    if (rst == `Enable) begin
      exop_out = `ALUOP_NOP;
      wreg_wen_out = `Disable;
      reg1_ren_out = `Disable;
      reg2_ren_out = `Disable;
      immed = `ZeroWord;
      ins_out = `ZeroWord;
    // ���������߼�
    end else begin
      ins_out = ins_in; // ֱ�����´���
      // �ȸ�Ĭ��ֵ��������Щָ���Ҫ�޸�����һЩֵʱ���ִ���
      exop_out = `ALUOP_NOP; // ALU û�в���
      // ��ֹ���ʹ��
      wreg_wen_out = `Disable;
      reg1_ren_out = `Disable;
      reg2_ren_out = `Disable;
      // ��0��
      immed = `ZeroWord;
      // û�з�֧
      link_addr_out = `ZeroWord;
      next_in_delayslot_out = `Disable;
      branch_en_out = `Disable;
      branch_addr_out = `ZeroWord;
      // û���쳣��Ϣ
      abnormal_type_out = `ZeroWord;
      // ��ָ���ַ���´�
      current_id_pc_addr_out = pc_in;
      // ����op����
      if (ins_in == 32'd0) begin
        // nop
      end else begin
        // R��ָ��
      if (op == `OP_RTYPE) begin
        case (func)
          `FUNC_OR: begin
            wreg_wen_out = `Enable;
            wreg_addr_out = rd;
            reg1_ren_out = `Enable;
            reg1_addr_out = rs;
            reg2_ren_out = `Enable;
            reg2_addr_out = rt;
            exop_out = `ALUOP_OR;
          end
          `FUNC_AND: begin
            wreg_wen_out = `Enable;
            wreg_addr_out = rd;
            reg1_ren_out = `Enable;
            reg1_addr_out = rs;
            reg2_ren_out = `Enable;
            reg2_addr_out = rt;
            exop_out = `ALUOP_AND;  
          end
          `FUNC_XOR: begin
            wreg_wen_out = `Enable;
            wreg_addr_out = rd;
            reg1_ren_out = `Enable;
            reg1_addr_out = rs;
            reg2_ren_out = `Enable;
            reg2_addr_out = rt;
            exop_out = `ALUOP_XOR;
          end
          `FUNC_NOR: begin
            wreg_wen_out = `Enable;
            wreg_addr_out = rd;
            reg1_ren_out = `Enable;
            reg1_addr_out = rs;
            reg2_ren_out = `Enable;
            reg2_addr_out = rt;
            exop_out = `ALUOP_NOR;
          end
          `FUNC_SLLV: begin
            wreg_wen_out = `Enable;
            wreg_addr_out = rd;
            reg1_ren_out = `Enable;
            reg1_addr_out = rs;
            reg2_ren_out = `Enable;
            reg2_addr_out = rt;
            exop_out = `ALUOP_SLL;
          end
          `FUNC_SRLV: begin
            wreg_wen_out = `Enable;
            wreg_addr_out = rd;
            reg1_ren_out = `Enable;
            reg1_addr_out = rs;
            reg2_ren_out = `Enable;
            reg2_addr_out = rt;
            exop_out = `ALUOP_SRL;
          end
          `FUNC_SRAV: begin
            wreg_wen_out = `Enable;
            wreg_addr_out = rd;
            reg1_ren_out = `Enable;
            reg1_addr_out = rs;
            reg2_ren_out = `Enable;
            reg2_addr_out = rt;
            exop_out = `ALUOP_SRA;
          end
          `FUNC_SLL: begin
            wreg_wen_out = `Enable;
            wreg_addr_out = rd;
            reg1_ren_out = `Disable;
            reg2_ren_out = `Enable;
            reg2_addr_out = rt;
            immed = {27'h0, shamt};
            exop_out = `ALUOP_SLL;
          end
          `FUNC_SRL: begin
            wreg_wen_out = `Enable;
            wreg_addr_out = rd;
            reg1_ren_out = `Disable;
            reg2_ren_out = `Enable;
            reg2_addr_out = rt;
            immed = {27'h0, shamt};
            exop_out = `ALUOP_SRL;
          end
          `FUNC_SRA: begin
            wreg_wen_out = `Enable;
            wreg_addr_out = rd;
            reg1_ren_out = `Disable;
            reg2_ren_out = `Enable;
            reg2_addr_out = rt;
            immed = {27'h0, shamt};
            exop_out = `ALUOP_SRA;
          end
          // HILO���
          // ע��HI/LO����32���Ĵ�����GPR�У�ʹ�ܲ�Ҫ����
          `FUNC_MFHI: begin
            wreg_wen_out = `Enable;
            wreg_addr_out = rd;
            reg1_ren_out = `Disable;
            reg2_ren_out = `Disable;
            exop_out = `EXOP_MFHI;
          end
          `FUNC_MFLO: begin
            wreg_wen_out = `Enable;
            wreg_addr_out = rd;
            reg1_ren_out = `Disable;
            reg2_ren_out = `Disable;
            exop_out = `EXOP_MFLO;
          end
          `FUNC_MTHI: begin
            wreg_wen_out = `Disable;
            exop_out = `EXOP_MTHI;
            reg1_ren_out = `Enable;
            reg1_addr_out = rs;
            reg2_ren_out = `Disable;
          end
          `FUNC_MTLO: begin
            wreg_wen_out = `Disable;
            reg1_ren_out = `Enable;
            reg1_addr_out = rs;
            reg2_ren_out = `Disable;
            exop_out = `EXOP_MTLO;
          end
          `FUNC_SLT: begin
            wreg_wen_out = `Enable;
            wreg_addr_out = rd;
            reg1_ren_out = `Enable;
            reg1_addr_out = rs;
            reg2_ren_out = `Enable;
            reg2_addr_out = rt;
            exop_out = `ALUOP_SLT;
          end
          `FUNC_SLTU: begin
            wreg_wen_out = `Enable;
            wreg_addr_out = rd;
            reg1_ren_out = `Enable;
            reg1_addr_out = rs;
            reg2_ren_out = `Enable;
            reg2_addr_out = rt;
            exop_out = `ALUOP_SLTU;
          end
          `FUNC_ADD: begin
            wreg_wen_out = `Enable;
            wreg_addr_out = rd;
            reg1_ren_out = `Enable;
            reg1_addr_out = rs;
            reg2_ren_out = `Enable;
            reg2_addr_out = rt;
            exop_out = `ALUOP_ADD;
          end
          `FUNC_ADDU: begin
            wreg_wen_out = `Enable;
            wreg_addr_out = rd;
            reg1_ren_out = `Enable;
            reg1_addr_out = rs;
            reg2_ren_out = `Enable;
            reg2_addr_out = rt;
            exop_out = `ALUOP_ADDU;
          end
          `FUNC_SUB: begin
            wreg_wen_out = `Enable;
            wreg_addr_out = rd;
            reg1_ren_out = `Enable;
            reg1_addr_out = rs;
            reg2_ren_out = `Enable;
            reg2_addr_out = rt;
            exop_out = `ALUOP_SUB;
          end
          `FUNC_SUBU: begin
            wreg_wen_out = `Enable;
            wreg_addr_out = rd;
            reg1_ren_out = `Enable;
            reg1_addr_out = rs;
            reg2_ren_out = `Enable;
            reg2_addr_out = rt;
            exop_out = `ALUOP_SUBU;
          end
          `FUNC_DIV: begin
            wreg_wen_out = `Disable;
            reg1_ren_out = `Enable;
            reg1_addr_out = rs;
            reg2_ren_out = `Enable;
            reg2_addr_out = rt;
            exop_out = `ALUOP_DIV;
          end
          `FUNC_DIVU: begin
            wreg_wen_out = `Disable;
            reg1_ren_out = `Enable;
            reg1_addr_out = rs;
            reg2_ren_out = `Enable;
            reg2_addr_out = rt;
            exop_out = `ALUOP_DIVU;
          end
          `FUNC_MULT: begin
            wreg_wen_out = `Disable;
            reg1_ren_out = `Enable;
            reg1_addr_out = rs;
            reg2_ren_out = `Enable;
            reg2_addr_out = rt;
            exop_out = `ALUOP_MULT;
          end
          `FUNC_MULTU: begin
            wreg_wen_out = `Disable;
            reg1_ren_out = `Enable;
            reg1_addr_out = rs;
            reg2_ren_out = `Enable;
            reg2_addr_out = rt;
            exop_out = `ALUOP_MULTU;
          end
          // ��ת��
          `FUNC_JR: begin   // rs->pc
            wreg_wen_out = `Disable;
            reg1_ren_out = `Enable;
            reg1_addr_out = rs;
            reg2_ren_out = `Disable;
            branch_en_out = `Enable;
            branch_addr_out = data1_out;
            next_in_delayslot_out = `Enable;
            exop_out = `EXOP_JR;
          end
          `FUNC_JALR: begin  // rd<-PC+4��PC<-rs
            wreg_wen_out = `Enable;
            wreg_addr_out = rd;
            reg1_ren_out = `Enable;
            reg1_addr_out = rs;
            reg2_ren_out = `Disable;
            branch_en_out = `Enable;
            branch_addr_out = data1_out;
            // Link���������淵�ص�ַ��PC+8
            link_addr_out = pc_in + 32'd8;
            next_in_delayslot_out = `Enable;
            exop_out = `EXOP_JALR;
          end
          //�쳣���
          `FUNC_SYSCALL :begin
            wreg_wen_out = `Disable;
            reg1_ren_out = `Disable;
            reg2_ren_out = `Disable;
            exop_out = `EXOP_SYSTEMCALL;
            abnormal_type_out[6:2] = `ABN_SYSTEMCALL;
          end
          `FUNC_BREAK :begin
            wreg_wen_out = `Disable;
            reg1_ren_out = `Disable;
            reg2_ren_out = `Disable;
            exop_out = `EXOP_SYSTEMCALL;
            abnormal_type_out[6:2] = `ABN_BREAK;
          end
        endcase
      end else begin
        // I���J��
        case (op)
          `OP_ORI: begin
            wreg_wen_out = `Enable;
            wreg_addr_out = rt;
            reg1_ren_out = `Enable;
            reg1_addr_out = rs;
            reg2_ren_out = `Disable;
            immed = {16'h0, ins_in[`ImmedRange]};
            exop_out = `ALUOP_OR;
          end
          `OP_ANDI: begin
            wreg_wen_out = `Enable;
            wreg_addr_out = rt;
            reg1_ren_out = `Enable;
            reg1_addr_out = rs;
            reg2_ren_out = `Disable;
            immed = {16'h0, ins_in[`ImmedRange]};
            exop_out = `ALUOP_AND;
          end
          `OP_XORI: begin
            wreg_wen_out = `Enable;
            wreg_addr_out = rt;
            reg1_ren_out = `Enable;
            reg1_addr_out = rs;
            reg2_ren_out = `Disable;
            immed = {16'h0, ins_in[`ImmedRange]};
            exop_out = `ALUOP_XOR;
          end
          `OP_LUI: begin
            // ����rs=$0�����ԣ��ɵȼ�����ʵ��
            wreg_wen_out = `Enable;
            wreg_addr_out = rt;
            reg1_ren_out = `Enable;
            reg1_addr_out = rs;
            reg2_ren_out = `Disable;
            immed = {ins_in[`ImmedRange], 16'h0};
            exop_out = `ALUOP_OR;
          end
          `OP_SLTI: begin
            wreg_wen_out = `Enable;
            wreg_addr_out = rt;
            reg1_ren_out = `Enable;
            reg1_addr_out = rs;
            reg2_ren_out = `Disable;
            immed = {{16{ins_in[15]}}, ins_in[15:0]}; // sign-ext
            exop_out = `ALUOP_SLT;
          end
          `OP_SLTIU: begin
            wreg_wen_out = `Enable;
            wreg_addr_out = rt;
            reg1_ren_out = `Enable;
            reg1_addr_out = rs;
            reg2_ren_out = `Disable;
            immed = {{16{ins_in[15]}}, ins_in[15:0]}; // sign-ext
            exop_out = `ALUOP_SLTU;
          end
          `OP_ADDI: begin
            wreg_wen_out = `Enable;
            wreg_addr_out = rt;
            reg1_ren_out = `Enable;
            reg1_addr_out = rs;
            reg2_ren_out = `Disable;
            immed = {{16{ins_in[15]}}, ins_in[15:0]}; // sign-ext
            exop_out = `ALUOP_ADD;
          end
          `OP_ADDIU: begin
            wreg_wen_out = `Enable;
            wreg_addr_out = rt;
            reg1_ren_out = `Enable;
            reg1_addr_out = rs;
            reg2_ren_out = `Disable;
            immed = {{16{ins_in[15]}}, ins_in[15:0]}; // sign-ext
            exop_out = `ALUOP_ADDU;
          end
          `OP_J: begin
            wreg_wen_out = `Disable;
            reg1_ren_out = `Disable;
            reg2_ren_out = `Disable;
            branch_en_out = `Enable;
            branch_addr_out = {4'b0000, address[25:0], 2'b00};
            next_in_delayslot_out = `Enable;
            exop_out = `EXOP_J;
          end
          `OP_JAL: begin
            wreg_wen_out = `Enable;
            wreg_addr_out = `RegCountLog2'd31; // �̶���$ra
            reg1_ren_out = `Disable;
            reg2_ren_out = `Disable;
            branch_en_out = `Enable;
            branch_addr_out = {4'b0000, address[25:0], 2'b00};
            // Link����
            link_addr_out = pc_in + 32'd8;
            next_in_delayslot_out = `Enable;
            exop_out = `EXOP_JAL;
          end
          `OP_BEQ: begin
            wreg_wen_out = `Disable;
            exop_out = `EXOP_BEQ;
            reg1_ren_out = `Enable;
            reg1_addr_out = rs;
            reg2_ren_out = `Enable;
            reg2_addr_out = rt;
            branch_en_out = `Disable;
            if (data1_out == data2_out) begin
              branch_en_out = `Enable;
              branch_addr_out = pc_in + 32'd4 + {{14{offset[15]}}, offset[15:0], 2'b00};
              next_in_delayslot_out = `Enable;
            end
          end
          `OP_BGTZ: begin
            wreg_wen_out = `Disable;
            exop_out = `EXOP_BGTZ;
            reg1_ren_out = `Enable;
            reg1_addr_out = rs;
            reg2_ren_out = `Disable;
            branch_en_out = `Disable;
            // �жϱ�0��
            if (data1_out[31] == 1'b0 && data1_out != `ZeroWord) begin
              branch_en_out = `Enable;
              branch_addr_out = pc_in + 32'd4 + {{14{offset[15]}}, offset[15:0], 2'b00};
              next_in_delayslot_out = `Enable;
            end
          end
          `OP_BLEZ: begin
            wreg_wen_out = `Disable;
            exop_out = `EXOP_BLEZ;
            reg1_ren_out = `Enable;
            reg1_addr_out = rs;
            reg2_ren_out = `Disable;
            branch_en_out = `Disable;
            // �жϱ���С�����
            if (data1_out[31] == 1'b1 || data1_out == `ZeroWord) begin
              branch_en_out = `Enable;
              branch_addr_out = pc_in + 32'd4 + {{14{offset[15]}}, offset[15:0], 2'b00};
              next_in_delayslot_out = `Enable;
            end
          end
          `OP_BNE: begin
            wreg_wen_out = `Disable;
            exop_out = `EXOP_BNE;
            reg1_ren_out = `Enable;
            reg1_addr_out = rs;
            reg2_ren_out = `Enable;
            reg2_addr_out = rt;
            branch_en_out = `Disable;
            if (data1_out != data2_out) begin
              branch_en_out = `Enable;
              branch_addr_out = pc_in + 32'd4 + {{14{offset[15]}}, offset[15:0], 2'b00};
              next_in_delayslot_out = `Enable;
            end
          end
          `OP_BGEZ: begin // bgez, bltz, bgezal, bltzal���п���
            if (rt == 5'b00001) begin // bgez
              wreg_wen_out = `Disable;
              exop_out = `EXOP_BGEZ;
              reg1_ren_out = `Enable;
              reg1_addr_out = rs;
              reg2_ren_out = `Disable;
              branch_en_out = `Disable;
              if (data1_out[31] == 1'b0) begin
                branch_en_out = `Enable;
                branch_addr_out = pc_in + 32'd4 + {{14{offset[15]}}, offset[15:0], 2'b00};
                next_in_delayslot_out = `Enable;
              end
            end else if (rt == 5'b00000) begin // bltz
              wreg_wen_out = `Disable;
              exop_out = `EXOP_BGEZ;
              reg1_ren_out = `Enable;
              reg1_addr_out = rs;
              reg2_ren_out = `Disable;
              branch_en_out = `Disable;
              if (data1_out[31] == 1'b1) begin
                branch_en_out = `Enable;
                branch_addr_out = pc_in + 32'd4 + {{14{offset[15]}}, offset[15:0], 2'b00};
                next_in_delayslot_out = `Enable;
              end
            end else if (rt == 5'b10001) begin // bgezal
              wreg_wen_out = `Enable;
              wreg_addr_out = `RegCountLog2'd31;
              reg1_ren_out = `Enable;
              reg1_addr_out = rs;
              reg2_ren_out = `Disable;
              link_addr_out = pc_in + 32'd8;
              exop_out = `EXOP_BGEZAL;
              branch_en_out = `Disable;
              if (data1_out[31] == 1'b0) begin
                branch_en_out = `Enable;
                branch_addr_out = pc_in + 32'd4 + {{14{offset[15]}}, offset[15:0], 2'b00};
                next_in_delayslot_out = `Enable;
              end
            end else if(rt == 5'b10000) begin // bltzal
              wreg_wen_out = `Enable;
              wreg_addr_out = `RegCountLog2'd31;
              reg1_ren_out = `Enable;
              reg1_addr_out = rs;
              reg2_ren_out = `Disable;
              link_addr_out = pc_in + 32'd8;
              exop_out = `EXOP_BLTZAL;
              branch_en_out = `Disable;
              if (data1_out[31] == 1'b1) begin
                branch_en_out = `Enable;
                branch_addr_out = pc_in + 32'd4 + {{14{offset[15]}}, offset[15:0], 2'b00};
                next_in_delayslot_out = `Enable;
              end
            end  
          end
          // �ô����ָ��
          `OP_LB: begin
            wreg_wen_out = `Enable;
            wreg_addr_out = rt;
            exop_out = `EXOP_LB;
            reg1_ren_out = `Enable;
            reg1_addr_out = rs;
            reg2_ren_out = `Disable;
          end
          `OP_LBU: begin
            wreg_wen_out = `Enable;
            wreg_addr_out = rt;
            exop_out = `EXOP_LBU;
            reg1_ren_out = `Enable;
            reg1_addr_out = rs;
            reg2_ren_out = `Disable;
          end
          `OP_LH: begin
            wreg_wen_out = `Enable;
            wreg_addr_out = rt;
            exop_out = `EXOP_LH;
            reg1_ren_out = `Enable;
            reg1_addr_out = rs;
            reg2_ren_out = `Disable;
          end
          `OP_LHU: begin
            wreg_wen_out = `Enable;
            wreg_addr_out = rt;
            exop_out = `EXOP_LHU;
            reg1_ren_out = `Enable;
            reg1_addr_out = rs;
            reg2_ren_out = `Disable;
          end
          `OP_SB: begin
            wreg_wen_out = `Disable;
            exop_out = `EXOP_SB;
            reg1_ren_out = `Enable;
            reg1_addr_out = rs;
            reg2_ren_out = `Enable;
            reg2_addr_out = rt;
          end
          `OP_SH: begin
            wreg_wen_out = `Disable;
            exop_out = `EXOP_SH;
            reg1_ren_out = `Enable;
            reg1_addr_out = rs;
            reg2_ren_out = `Enable;
            reg2_addr_out = rt;
          end
          `OP_LW: begin
            wreg_wen_out = `Enable;
            wreg_addr_out = rt;
            exop_out = `EXOP_LW;
            reg1_ren_out = `Enable;
            reg1_addr_out = rs;
            reg2_ren_out = `Disable;
          end
          `OP_SW: begin
            wreg_wen_out = `Disable;
            exop_out = `EXOP_SW;
            reg1_ren_out = `Enable;
            reg1_addr_out = rs;
            reg2_ren_out = `Enable;
            reg2_addr_out = rt;
          end
          `OP_CP0: begin
            if (rs == 5'b00000) begin // ��mfc0
              wreg_wen_out = `Enable;
              wreg_addr_out = rt;
              exop_out = `EXOP_MFC0;
              reg1_ren_out = `Disable;
              reg2_ren_out = `Disable;
            end
            if (rs == 5'b00100) begin // ��mtc0
              wreg_wen_out = `Disable;
              exop_out = `EXOP_MTC0;
              reg1_ren_out = `Enable;
              reg1_addr_out = rt;
              reg2_ren_out = `Disable;
            end
            if(ins_in[25:0] == 26'b10000000000000000000011000) begin // ��eretָ��
              wreg_wen_out = `Disable;
              exop_out = `EXOP_ERET;
              reg1_ren_out = `Disable;
              reg2_ren_out = `Disable;
              abnormal_type_out[6:2] = `ABN_ERET;
            end 
          end
          default: begin
          end
        endcase
      end
      end
    end
  end

  always @(rst or in_delayslot_in) begin
    if (rst == `Enable) begin
      in_delayslot_out = `Disable;     
    end else begin
      in_delayslot_out = in_delayslot_in;
    end
  end

  // ���濪ʼȷ���͵�EX�����ݾ�������������
  // ��ȡ������Դ�ǼĴ���������������
  always @(*) begin
    // rstʱ�̶���0x0
    if (rst == `Enable) begin
      data1_out = `ZeroWord;
    // ������0����ID-EX������ˮ�������
    // ���ǰ���EXҪд�ľ��Ǻ����IDҪ���ģ���͸��ת����
    end else if (ex_wreg_en_in == `Enable && reg1_ren_out == `Enable && reg1_addr_out == ex_wreg_addr_in) begin
      data1_out = ex_wreg_data_in;
    // ������1����ID-MEM������ˮ�������
    // ���ǰ���MEMҪд�ľ��Ǻ����IDҪ���ģ���͸��ת����
    end else if (mem_wreg_en_in == `Enable && reg1_ren_out == `Enable && reg1_addr_out == mem_wreg_addr_in) begin
      data1_out = mem_wreg_data_in;  
    // ���ָ������Ľ����Ҫ��reg1����˵��������1���ԼĴ�����rs��
    end else if (reg1_ren_out == `Enable) begin
      data1_out = reg1_data_in;
    // ���ָ������Ľ������Ҫ��reg1����˵��������1��������
    end else if (reg1_ren_out == `Disable) begin
      data1_out = immed;
    // ����
    end else begin
      data1_out = `ZeroWord;
    end
  end

  // �߼�ͬ��
  always @(*) begin
    if (rst == `Enable) begin
      data2_out = `ZeroWord;
    end else if (ex_wreg_en_in == `Enable && reg2_ren_out == `Enable && reg2_addr_out == ex_wreg_addr_in) begin
      data2_out = ex_wreg_data_in;
    end else if (mem_wreg_en_in == `Enable && reg2_ren_out == `Enable && reg2_addr_out == mem_wreg_addr_in) begin
      data2_out = mem_wreg_data_in;  
    end else if (reg2_ren_out == `Enable) begin //��rt��
      data2_out = reg2_data_in;
    end else if (reg2_ren_out == `Disable) begin
      data2_out = immed;
    end else begin
      data2_out = `ZeroWord;
    end
  end

endmodule
