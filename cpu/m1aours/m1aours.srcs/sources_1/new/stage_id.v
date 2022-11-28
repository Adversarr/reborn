//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/11/23 09:54:08
// Design Name: 
// Module Name: stage_id
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

module stage_id(
    input wire rst,
    input wire [`WordRange] pc_in,
    input wire [`WordRange] ins_in,
    
    // Register IO:
    input wire [`WordRange] reg1_data_in,
    input wire [`WordRange] reg2_data_in,
    output reg reg1_read_enable_out,
    output reg reg2_read_enable_out,
    output reg [`WordRange] reg1_read_addr_out,
    output reg [`WordRange] reg2_read_addr_out,
    // ALU:
    output reg [`ALUOpRange] alu_op_out,
    // Source Operands
    output reg [`WordRange] data1_out,
    output reg [`WordRange] data2_out,
    // Writes to reg?
    output reg reg_write_enable_out,
    output reg [`RegRangeLog2] reg_write_addr_out,
    // Data Correlated => From EX
    input ex_write_reg_enable_in,
    input wire [`WordRange] ex_write_reg_data_in,
    input wire [`RegRangeLog2] ex_write_reg_addr_in,
    // Data Correlated => From MEM
    input mem_write_reg_enable_in,
    input wire [`WordRange] mem_write_reg_data_in,
    input wire [`RegRangeLog2] mem_write_reg_addr_in,
    // Pipeline Stall Req Signal:
    output reg pause_out,
    // delay-slot: Reference pdf Page206
    input wire is_in_delayslot_in,  // current instr is in slot.
    output reg is_in_delayslot_out, // current instr is in slot.
    output reg next_is_in_delayslot_out,  // next instr is in slot.
    // Branch:
    output reg branch_enable_out,
    output reg[`WordRange] branch_addr_out,
    output reg[`WordRange] link_addr_out,
    output reg[`WordRange] ins_out,
    // Interruption
      // abnormal_type_out
    // 31...12 Ԥ��
    // 11 eret
    // 10 systemcall
    // 9...8 abnormal info
    // 7...0 interrupt info
    output reg[`WordRange] abnormal_type_out,     // information about instr
    output reg[`WordRange] current_id_pc_addr_out
);
  wire[5:0] op = ins_in[`OpRange];
  wire[4:0] rs = ins_in[`RsRange];
  wire[4:0] rt = ins_in[`RtRange];
  wire[4:0] rd = ins_in[`RdRange];
  wire[4:0] shamt = ins_in[`ShamtRange];
  wire[5:0] func = ins_in[`FuncRange];
  wire[15:0] immediate = ins_in[`ImmedRange];
  wire[15:0] offset = ins_in[`OffsetRange];
  wire[25:0] address = ins_in[`AddressRange];

  // Signed/Unsigned Extended immediate operand
  reg[`WordRange] immed;
 

    // ָ������
    always @(*) begin
      // rstʱ�ص�����ʹ�ܣ����������
      if (rst == `Enable) begin
        alu_op_out = `ALUOP_NOP;
        reg_write_enable_out = `Disable;
        reg1_read_enable_out = `Disable;
        reg2_read_enable_out = `Disable;
        immed = `ZeroWord;
        ins_out = `ZeroWord;
      // ���������߼�
      end else begin
        ins_out = ins_in; // ֱ�����´���
        // �ȸ�Ĭ��ֵ��������Щָ���Ҫ�޸�����һЩֵʱ���ִ���
        alu_op_out = `ALUOP_NOP; // ALU û�в���
        // ��ֹ���ʹ��
        reg_write_enable_out = `Disable;
        reg1_read_enable_out = `Disable;
        reg2_read_enable_out = `Disable;
        // ��0��
        immed = `ZeroWord;
        // û�з�֧
        link_addr_out = `ZeroWord;
        next_is_in_delayslot_out = `Disable;
        branch_enable_out = `Disable;
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
              reg_write_enable_out = `Enable;
              reg_write_addr_out = rd;
              reg1_read_enable_out = `Enable;
              reg1_read_addr_out = rs;
              reg2_read_enable_out = `Enable;
              reg2_read_addr_out = rt;
              alu_op_out = `ALUOP_OR;
            end
            `FUNC_AND: begin
              reg_write_enable_out = `Enable;
              reg_write_addr_out = rd;
              reg1_read_enable_out = `Enable;
              reg1_read_addr_out = rs;
              reg2_read_enable_out = `Enable;
              reg2_read_addr_out = rt;
              alu_op_out = `ALUOP_AND;  
            end
            `FUNC_XOR: begin
              reg_write_enable_out = `Enable;
              reg_write_addr_out = rd;
              reg1_read_enable_out = `Enable;
              reg1_read_addr_out = rs;
              reg2_read_enable_out = `Enable;
              reg2_read_addr_out = rt;
              alu_op_out = `ALUOP_XOR;
            end
            `FUNC_NOR: begin
              reg_write_enable_out = `Enable;
              reg_write_addr_out = rd;
              reg1_read_enable_out = `Enable;
              reg1_read_addr_out = rs;
              reg2_read_enable_out = `Enable;
              reg2_read_addr_out = rt;
              alu_op_out = `ALUOP_NOR;
            end
            `FUNC_SLLV: begin
              reg_write_enable_out = `Enable;
              reg_write_addr_out = rd;
              reg1_read_enable_out = `Enable;
              reg1_read_addr_out = rs;
              reg2_read_enable_out = `Enable;
              reg2_read_addr_out = rt;
              alu_op_out = `ALUOP_SLL;
            end
            `FUNC_SRLV: begin
              reg_write_enable_out = `Enable;
              reg_write_addr_out = rd;
              reg1_read_enable_out = `Enable;
              reg1_read_addr_out = rs;
              reg2_read_enable_out = `Enable;
              reg2_read_addr_out = rt;
              alu_op_out = `ALUOP_SRL;
            end
            `FUNC_SRAV: begin
              reg_write_enable_out = `Enable;
              reg_write_addr_out = rd;
              reg1_read_enable_out = `Enable;
              reg1_read_addr_out = rs;
              reg2_read_enable_out = `Enable;
              reg2_read_addr_out = rt;
              alu_op_out = `ALUOP_SRA;
            end
            `FUNC_SLL: begin
              reg_write_enable_out = `Enable;
              reg_write_addr_out = rd;
              reg1_read_enable_out = `Disable;
              reg2_read_enable_out = `Enable;
              reg2_read_addr_out = rt;
              immed = {27'h0, shamt};
              alu_op_out = `ALUOP_SLL;
            end
            `FUNC_SRL: begin
              reg_write_enable_out = `Enable;
              reg_write_addr_out = rd;
              reg1_read_enable_out = `Disable;
              reg2_read_enable_out = `Enable;
              reg2_read_addr_out = rt;
              immed = {27'h0, shamt};
              alu_op_out = `ALUOP_SRL;
            end
            `FUNC_SRA: begin
              reg_write_enable_out = `Enable;
              reg_write_addr_out = rd;
              reg1_read_enable_out = `Disable;
              reg2_read_enable_out = `Enable;
              reg2_read_addr_out = rt;
              immed = {27'h0, shamt};
              alu_op_out = `ALUOP_SRA;
            end
            // HILO���
            // ע��HI/LO����32���Ĵ�����GPR�У�ʹ�ܲ�Ҫ����
            `FUNC_MFHI: begin
              reg_write_enable_out = `Enable;
              reg_write_addr_out = rd;
              reg1_read_enable_out = `Disable;
              reg2_read_enable_out = `Disable;
              alu_op_out = `EXOP_MFHI;
            end
            `FUNC_MFLO: begin
              reg_write_enable_out = `Enable;
              reg_write_addr_out = rd;
              reg1_read_enable_out = `Disable;
              reg2_read_enable_out = `Disable;
              alu_op_out = `EXOP_MFLO;
            end
            `FUNC_MTHI: begin
              reg_write_enable_out = `Disable;
              alu_op_out = `EXOP_MTHI;
              reg1_read_enable_out = `Enable;
              reg1_read_addr_out = rs;
              reg2_read_enable_out = `Disable;
            end
            `FUNC_MTLO: begin
              reg_write_enable_out = `Disable;
              reg1_read_enable_out = `Enable;
              reg1_read_addr_out = rs;
              reg2_read_enable_out = `Disable;
              alu_op_out = `EXOP_MTLO;
            end
            `FUNC_SLT: begin
              reg_write_enable_out = `Enable;
              reg_write_addr_out = rd;
              reg1_read_enable_out = `Enable;
              reg1_read_addr_out = rs;
              reg2_read_enable_out = `Enable;
              reg2_read_addr_out = rt;
              alu_op_out = `ALUOP_SLT;
            end
            `FUNC_SLTU: begin
              reg_write_enable_out = `Enable;
              reg_write_addr_out = rd;
              reg1_read_enable_out = `Enable;
              reg1_read_addr_out = rs;
              reg2_read_enable_out = `Enable;
              reg2_read_addr_out = rt;
              alu_op_out = `ALUOP_SLTU;
            end
            `FUNC_ADD: begin
              reg_write_enable_out = `Enable;
              reg_write_addr_out = rd;
              reg1_read_enable_out = `Enable;
              reg1_read_addr_out = rs;
              reg2_read_enable_out = `Enable;
              reg2_read_addr_out = rt;
              alu_op_out = `ALUOP_ADD;
            end
            `FUNC_ADDU: begin
              reg_write_enable_out = `Enable;
              reg_write_addr_out = rd;
              reg1_read_enable_out = `Enable;
              reg1_read_addr_out = rs;
              reg2_read_enable_out = `Enable;
              reg2_read_addr_out = rt;
              alu_op_out = `ALUOP_ADDU;
            end
            `FUNC_SUB: begin
              reg_write_enable_out = `Enable;
              reg_write_addr_out = rd;
              reg1_read_enable_out = `Enable;
              reg1_read_addr_out = rs;
              reg2_read_enable_out = `Enable;
              reg2_read_addr_out = rt;
              alu_op_out = `ALUOP_SUB;
            end
            `FUNC_SUBU: begin
              reg_write_enable_out = `Enable;
              reg_write_addr_out = rd;
              reg1_read_enable_out = `Enable;
              reg1_read_addr_out = rs;
              reg2_read_enable_out = `Enable;
              reg2_read_addr_out = rt;
              alu_op_out = `ALUOP_SUBU;
            end
            `FUNC_DIV: begin
              reg_write_enable_out = `Disable;
              reg1_read_enable_out = `Enable;
              reg1_read_addr_out = rs;
              reg2_read_enable_out = `Enable;
              reg2_read_addr_out = rt;
              alu_op_out = `ALUOP_DIV;
            end
            `FUNC_DIVU: begin
              reg_write_enable_out = `Disable;
              reg1_read_enable_out = `Enable;
              reg1_read_addr_out = rs;
              reg2_read_enable_out = `Enable;
              reg2_read_addr_out = rt;
              alu_op_out = `ALUOP_DIVU;
            end
            `FUNC_MULT: begin
              reg_write_enable_out = `Disable;
              reg1_read_enable_out = `Enable;
              reg1_read_addr_out = rs;
              reg2_read_enable_out = `Enable;
              reg2_read_addr_out = rt;
              alu_op_out = `ALUOP_MULT;
            end
            `FUNC_MULTU: begin
              reg_write_enable_out = `Disable;
              reg1_read_enable_out = `Enable;
              reg1_read_addr_out = rs;
              reg2_read_enable_out = `Enable;
              reg2_read_addr_out = rt;
              alu_op_out = `ALUOP_MULTU;
            end
            // ��ת��
            `FUNC_JR: begin   // rs->pc
              reg_write_enable_out = `Disable;
              reg1_read_enable_out = `Enable;
              reg1_read_addr_out = rs;
              reg2_read_enable_out = `Disable;
              branch_enable_out = `Enable;
              branch_addr_out = data1_out;
              next_is_in_delayslot_out = `Enable;
              alu_op_out = `EXOP_JR;
            end
            `FUNC_JALR: begin  // rd<-PC+4��PC<-rs
              reg_write_enable_out = `Enable;
              reg_write_addr_out = rd;
              reg1_read_enable_out = `Enable;
              reg1_read_addr_out = rs;
              reg2_read_enable_out = `Disable;
              branch_enable_out = `Enable;
              branch_addr_out = data1_out;
              // Link���������淵�ص�ַ��PC+8
              link_addr_out = pc_in + 32'd8;
              next_is_in_delayslot_out = `Enable;
              alu_op_out = `EXOP_JALR;
            end
            //�쳣���
            `FUNC_SYSCALL :begin
              reg_write_enable_out = `Disable;
              reg1_read_enable_out = `Disable;
              reg2_read_enable_out = `Disable;
              alu_op_out = `EXOP_SYSTEMCALL;
              abnormal_type_out[6:2] = `ABN_SYSTEMCALL;
            end
            `FUNC_BREAK :begin
              reg_write_enable_out = `Disable;
              reg1_read_enable_out = `Disable;
              reg2_read_enable_out = `Disable;
              alu_op_out = `EXOP_SYSTEMCALL;
              abnormal_type_out[6:2] = `ABN_BREAK;
            end
          endcase
        end else begin
          // I���J��
          case (op)
            `OP_ORI: begin
              reg_write_enable_out = `Enable;
              reg_write_addr_out = rt;
              reg1_read_enable_out = `Enable;
              reg1_read_addr_out = rs;
              reg2_read_enable_out = `Disable;
              immed = {16'h0, ins_in[`ImmedRange]};
              alu_op_out = `ALUOP_OR;
            end
            `OP_ANDI: begin
              reg_write_enable_out = `Enable;
              reg_write_addr_out = rt;
              reg1_read_enable_out = `Enable;
              reg1_read_addr_out = rs;
              reg2_read_enable_out = `Disable;
              immed = {16'h0, ins_in[`ImmedRange]};
              alu_op_out = `ALUOP_AND;
            end
            `OP_XORI: begin
              reg_write_enable_out = `Enable;
              reg_write_addr_out = rt;
              reg1_read_enable_out = `Enable;
              reg1_read_addr_out = rs;
              reg2_read_enable_out = `Disable;
              immed = {16'h0, ins_in[`ImmedRange]};
              alu_op_out = `ALUOP_XOR;
            end
            `OP_LUI: begin
              // ����rs=$0�����ԣ��ɵȼ�����ʵ��
              reg_write_enable_out = `Enable;
              reg_write_addr_out = rt;
              reg1_read_enable_out = `Enable;
              reg1_read_addr_out = rs;
              reg2_read_enable_out = `Disable;
              immed = {ins_in[`ImmedRange], 16'h0};
              alu_op_out = `ALUOP_OR;
            end
            `OP_SLTI: begin
              reg_write_enable_out = `Enable;
              reg_write_addr_out = rt;
              reg1_read_enable_out = `Enable;
              reg1_read_addr_out = rs;
              reg2_read_enable_out = `Disable;
              immed = {{16{ins_in[15]}}, ins_in[15:0]}; // sign-ext
              alu_op_out = `ALUOP_SLT;
            end
            `OP_SLTIU: begin
              reg_write_enable_out = `Enable;
              reg_write_addr_out = rt;
              reg1_read_enable_out = `Enable;
              reg1_read_addr_out = rs;
              reg2_read_enable_out = `Disable;
              immed = {{16{ins_in[15]}}, ins_in[15:0]}; // sign-ext
              alu_op_out = `ALUOP_SLTU;
            end
            `OP_ADDI: begin
              reg_write_enable_out = `Enable;
              reg_write_addr_out = rt;
              reg1_read_enable_out = `Enable;
              reg1_read_addr_out = rs;
              reg2_read_enable_out = `Disable;
              immed = {{16{ins_in[15]}}, ins_in[15:0]}; // sign-ext
              alu_op_out = `ALUOP_ADD;
            end
            `OP_ADDIU: begin
              reg_write_enable_out = `Enable;
              reg_write_addr_out = rt;
              reg1_read_enable_out = `Enable;
              reg1_read_addr_out = rs;
              reg2_read_enable_out = `Disable;
              immed = {{16{ins_in[15]}}, ins_in[15:0]}; // sign-ext
              alu_op_out = `ALUOP_ADDU;
            end
            `OP_J: begin
              reg_write_enable_out = `Disable;
              reg1_read_enable_out = `Disable;
              reg2_read_enable_out = `Disable;
              branch_enable_out = `Enable;
              branch_addr_out = {4'b0000, address[25:0], 2'b00};
              next_is_in_delayslot_out = `Enable;
              alu_op_out = `EXOP_J;
            end
            `OP_JAL: begin
              reg_write_enable_out = `Enable;
              reg_write_addr_out = `RegCountLog2'd31; // �̶���$ra
              reg1_read_enable_out = `Disable;
              reg2_read_enable_out = `Disable;
              branch_enable_out = `Enable;
              branch_addr_out = {4'b0000, address[25:0], 2'b00};
              // Link����
              link_addr_out = pc_in + 32'd8;
              next_is_in_delayslot_out = `Enable;
              alu_op_out = `EXOP_JAL;
            end
            `OP_BEQ: begin
              reg_write_enable_out = `Disable;
              alu_op_out = `EXOP_BEQ;
              reg1_read_enable_out = `Enable;
              reg1_read_addr_out = rs;
              reg2_read_enable_out = `Enable;
              reg2_read_addr_out = rt;
              branch_enable_out = `Disable;
              if (data1_out == data2_out) begin
                branch_enable_out = `Enable;
                branch_addr_out = pc_in + 32'd4 + {{14{offset[15]}}, offset[15:0], 2'b00};
                next_is_in_delayslot_out = `Enable;
              end
            end
            `OP_BGTZ: begin
              reg_write_enable_out = `Disable;
              alu_op_out = `EXOP_BGTZ;
              reg1_read_enable_out = `Enable;
              reg1_read_addr_out = rs;
              reg2_read_enable_out = `Disable;
              branch_enable_out = `Disable;
              // �жϱ�0��
              if (data1_out[31] == 1'b0 && data1_out != `ZeroWord) begin
                branch_enable_out = `Enable;
                branch_addr_out = pc_in + 32'd4 + {{14{offset[15]}}, offset[15:0], 2'b00};
                next_is_in_delayslot_out = `Enable;
              end
            end
            `OP_BLEZ: begin
              reg_write_enable_out = `Disable;
              alu_op_out = `EXOP_BLEZ;
              reg1_read_enable_out = `Enable;
              reg1_read_addr_out = rs;
              reg2_read_enable_out = `Disable;
              branch_enable_out = `Disable;
              // �жϱ���С�����
              if (data1_out[31] == 1'b1 || data1_out == `ZeroWord) begin
                branch_enable_out = `Enable;
                branch_addr_out = pc_in + 32'd4 + {{14{offset[15]}}, offset[15:0], 2'b00};
                next_is_in_delayslot_out = `Enable;
              end
            end
            `OP_BNE: begin
              reg_write_enable_out = `Disable;
              alu_op_out = `EXOP_BNE;
              reg1_read_enable_out = `Enable;
              reg1_read_addr_out = rs;
              reg2_read_enable_out = `Enable;
              reg2_read_addr_out = rt;
              branch_enable_out = `Disable;
              if (data1_out != data2_out) begin
                branch_enable_out = `Enable;
                branch_addr_out = pc_in + 32'd4 + {{14{offset[15]}}, offset[15:0], 2'b00};
                next_is_in_delayslot_out = `Enable;
              end
            end
            `OP_BGEZ: begin // bgez, bltz, bgezal, bltzal���п���
              if (rt == 5'b00001) begin // bgez
                reg_write_enable_out = `Disable;
                alu_op_out = `EXOP_BGEZ;
                reg1_read_enable_out = `Enable;
                reg1_read_addr_out = rs;
                reg2_read_enable_out = `Disable;
                branch_enable_out = `Disable;
                if (data1_out[31] == 1'b0) begin
                  branch_enable_out = `Enable;
                  branch_addr_out = pc_in + 32'd4 + {{14{offset[15]}}, offset[15:0], 2'b00};
                  next_is_in_delayslot_out = `Enable;
                end
              end else if (rt == 5'b00000) begin // bltz
                reg_write_enable_out = `Disable;
                alu_op_out = `EXOP_BGEZ;
                reg1_read_enable_out = `Enable;
                reg1_read_addr_out = rs;
                reg2_read_enable_out = `Disable;
                branch_enable_out = `Disable;
                if (data1_out[31] == 1'b1) begin
                  branch_enable_out = `Enable;
                  branch_addr_out = pc_in + 32'd4 + {{14{offset[15]}}, offset[15:0], 2'b00};
                  next_is_in_delayslot_out = `Enable;
                end
              end else if (rt == 5'b10001) begin // bgezal
                reg_write_enable_out = `Enable;
                reg_write_addr_out = `RegCountLog2'd31;
                reg1_read_enable_out = `Enable;
                reg1_read_addr_out = rs;
                reg2_read_enable_out = `Disable;
                link_addr_out = pc_in + 32'd8;
                alu_op_out = `EXOP_BGEZAL;
                branch_enable_out = `Disable;
                if (data1_out[31] == 1'b0) begin
                  branch_enable_out = `Enable;
                  branch_addr_out = pc_in + 32'd4 + {{14{offset[15]}}, offset[15:0], 2'b00};
                  next_is_in_delayslot_out = `Enable;
                end
              end else if(rt == 5'b10000) begin // bltzal
                reg_write_enable_out = `Enable;
                reg_write_addr_out = `RegCountLog2'd31;
                reg1_read_enable_out = `Enable;
                reg1_read_addr_out = rs;
                reg2_read_enable_out = `Disable;
                link_addr_out = pc_in + 32'd8;
                alu_op_out = `EXOP_BLTZAL;
                branch_enable_out = `Disable;
                if (data1_out[31] == 1'b1) begin
                  branch_enable_out = `Enable;
                  branch_addr_out = pc_in + 32'd4 + {{14{offset[15]}}, offset[15:0], 2'b00};
                  next_is_in_delayslot_out = `Enable;
                end
              end  
            end
            // �ô����ָ��
            `OP_LB: begin
              reg_write_enable_out = `Enable;
              reg_write_addr_out = rt;
              alu_op_out = `EXOP_LB;
              reg1_read_enable_out = `Enable;
              reg1_read_addr_out = rs;
              reg2_read_enable_out = `Disable;
            end
            `OP_LBU: begin
              reg_write_enable_out = `Enable;
              reg_write_addr_out = rt;
              alu_op_out = `EXOP_LBU;
              reg1_read_enable_out = `Enable;
              reg1_read_addr_out = rs;
              reg2_read_enable_out = `Disable;
            end
            `OP_LH: begin
              reg_write_enable_out = `Enable;
              reg_write_addr_out = rt;
              alu_op_out = `EXOP_LH;
              reg1_read_enable_out = `Enable;
              reg1_read_addr_out = rs;
              reg2_read_enable_out = `Disable;
            end
            `OP_LHU: begin
              reg_write_enable_out = `Enable;
              reg_write_addr_out = rt;
              alu_op_out = `EXOP_LHU;
              reg1_read_enable_out = `Enable;
              reg1_read_addr_out = rs;
              reg2_read_enable_out = `Disable;
            end
            `OP_SB: begin
              reg_write_enable_out = `Disable;
              alu_op_out = `EXOP_SB;
              reg1_read_enable_out = `Enable;
              reg1_read_addr_out = rs;
              reg2_read_enable_out = `Enable;
              reg2_read_addr_out = rt;
            end
            `OP_SH: begin
              reg_write_enable_out = `Disable;
              alu_op_out = `EXOP_SH;
              reg1_read_enable_out = `Enable;
              reg1_read_addr_out = rs;
              reg2_read_enable_out = `Enable;
              reg2_read_addr_out = rt;
            end
            `OP_LW: begin
              reg_write_enable_out = `Enable;
              reg_write_addr_out = rt;
              alu_op_out = `EXOP_LW;
              reg1_read_enable_out = `Enable;
              reg1_read_addr_out = rs;
              reg2_read_enable_out = `Disable;
            end
            `OP_SW: begin
              reg_write_enable_out = `Disable;
              alu_op_out = `EXOP_SW;
              reg1_read_enable_out = `Enable;
              reg1_read_addr_out = rs;
              reg2_read_enable_out = `Enable;
              reg2_read_addr_out = rt;
            end
            `OP_CP0: begin
              if (rs == 5'b00000) begin // ��mfc0
                reg_write_enable_out = `Enable;
                reg_write_addr_out = rt;
                alu_op_out = `EXOP_MFC0;
                reg1_read_enable_out = `Disable;
                reg2_read_enable_out = `Disable;
              end
              if (rs == 5'b00100) begin // ��mtc0
                reg_write_enable_out = `Disable;
                alu_op_out = `EXOP_MTC0;
                reg1_read_enable_out = `Enable;
                reg1_read_addr_out = rt;
                reg2_read_enable_out = `Disable;
              end
              if(ins_in[25:0] == 26'b10000000000000000000011000) begin // ��eretָ��
                reg_write_enable_out = `Disable;
                alu_op_out = `EXOP_ERET;
                reg1_read_enable_out = `Disable;
                reg2_read_enable_out = `Disable;
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
  
    always @(rst or is_in_delayslot_in) begin
      if (rst == `Enable) begin
        is_in_delayslot_out = `Disable;     
      end else begin
        is_in_delayslot_out = is_in_delayslot_in;
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
      end else if (ex_write_reg_enable_in == `Enable && reg1_read_enable_out == `Enable && reg1_read_addr_out == ex_write_reg_addr_in) begin
        data1_out = ex_write_reg_data_in;
      // ������1����ID-MEM������ˮ�������
      // ���ǰ���MEMҪд�ľ��Ǻ����IDҪ���ģ���͸��ת����
      end else if (mem_write_reg_enable_in == `Enable && reg1_read_enable_out == `Enable && reg1_read_addr_out == mem_write_reg_addr_in) begin
        data1_out = mem_write_reg_data_in;  
      // ���ָ������Ľ����Ҫ��reg1����˵��������1���ԼĴ�����rs��
      end else if (reg1_read_enable_out == `Enable) begin
        data1_out = reg1_data_in;
      // ���ָ������Ľ������Ҫ��reg1����˵��������1��������
      end else if (reg1_read_enable_out == `Disable) begin
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
      end else if (ex_write_reg_enable_in == `Enable && reg2_read_enable_out == `Enable && reg2_read_addr_out == ex_write_reg_addr_in) begin
        data2_out = ex_write_reg_data_in;
      end else if (mem_write_reg_enable_in == `Enable && reg2_read_enable_out == `Enable && reg2_read_addr_out == mem_write_reg_addr_in) begin
        data2_out = mem_write_reg_data_in;  
      end else if (reg2_read_enable_out == `Enable) begin //��rt��
        data2_out = reg2_data_in;
      end else if (reg2_read_enable_out == `Disable) begin
        data2_out = immed;
      end else begin
        data2_out = `ZeroWord;
      end
    end

endmodule












