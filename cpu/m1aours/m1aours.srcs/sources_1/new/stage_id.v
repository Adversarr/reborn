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
    // 31...12 预留
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
 

    // 指令译码
    always @(*) begin
      // rst时关掉所有使能，清空立即数
      if (rst == `Enable) begin
        alu_op_out = `ALUOP_NOP;
        reg_write_enable_out = `Disable;
        reg1_read_enable_out = `Disable;
        reg2_read_enable_out = `Disable;
        immed = `ZeroWord;
        ins_out = `ZeroWord;
      // 具体译码逻辑
      end else begin
        ins_out = ins_in; // 直接向下传递
        // 先赋默认值，以免有些指令不需要修改其中一些值时出现错误
        alu_op_out = `ALUOP_NOP; // ALU 没有操作
        // 禁止相关使能
        reg_write_enable_out = `Disable;
        reg1_read_enable_out = `Disable;
        reg2_read_enable_out = `Disable;
        // 送0字
        immed = `ZeroWord;
        // 没有分支
        link_addr_out = `ZeroWord;
        next_is_in_delayslot_out = `Disable;
        branch_enable_out = `Disable;
        branch_addr_out = `ZeroWord;
        // 没有异常信息
        abnormal_type_out = `ZeroWord;
        // 把指令地址往下传
        current_id_pc_addr_out = pc_in;
        // 根据op翻译
        if (ins_in == 32'd0) begin
          // nop
        end else begin
          // R类指令
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
            // HILO相关
            // 注意HI/LO不在32个寄存器的GPR中，使能不要给错
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
            // 跳转类
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
            `FUNC_JALR: begin  // rd<-PC+4，PC<-rs
              reg_write_enable_out = `Enable;
              reg_write_addr_out = rd;
              reg1_read_enable_out = `Enable;
              reg1_read_addr_out = rs;
              reg2_read_enable_out = `Disable;
              branch_enable_out = `Enable;
              branch_addr_out = data1_out;
              // Link操作，保存返回地址是PC+8
              link_addr_out = pc_in + 32'd8;
              next_is_in_delayslot_out = `Enable;
              alu_op_out = `EXOP_JALR;
            end
            //异常相关
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
          // I类或J类
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
              // 借助rs=$0的特性，可等价如下实现
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
              reg_write_addr_out = `RegCountLog2'd31; // 固定是$ra
              reg1_read_enable_out = `Disable;
              reg2_read_enable_out = `Disable;
              branch_enable_out = `Enable;
              branch_addr_out = {4'b0000, address[25:0], 2'b00};
              // Link操作
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
              // 判断比0大
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
              // 判断比零小或相等
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
            `OP_BGEZ: begin // bgez, bltz, bgezal, bltzal都有可能
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
            // 访存相关指令
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
              if (rs == 5'b00000) begin // 是mfc0
                reg_write_enable_out = `Enable;
                reg_write_addr_out = rt;
                alu_op_out = `EXOP_MFC0;
                reg1_read_enable_out = `Disable;
                reg2_read_enable_out = `Disable;
              end
              if (rs == 5'b00100) begin // 是mtc0
                reg_write_enable_out = `Disable;
                alu_op_out = `EXOP_MTC0;
                reg1_read_enable_out = `Enable;
                reg1_read_addr_out = rt;
                reg2_read_enable_out = `Disable;
              end
              if(ins_in[25:0] == 26'b10000000000000000000011000) begin // 是eret指令
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
  
    // 下面开始确定送到EX的数据具体来自于哪里
    // 这取决于来源是寄存器，还是立即数
    always @(*) begin
      // rst时固定出0x0
      if (rst == `Enable) begin
        data1_out = `ZeroWord;
      // 解决相隔0条（ID-EX）的流水数据相关
      // 如果前面的EX要写的就是后面的ID要读的，则穿透（转发）
      end else if (ex_write_reg_enable_in == `Enable && reg1_read_enable_out == `Enable && reg1_read_addr_out == ex_write_reg_addr_in) begin
        data1_out = ex_write_reg_data_in;
      // 解决相隔1条（ID-MEM）的流水数据相关
      // 如果前面的MEM要写的就是后面的ID要读的，则穿透（转发）
      end else if (mem_write_reg_enable_in == `Enable && reg1_read_enable_out == `Enable && reg1_read_addr_out == mem_write_reg_addr_in) begin
        data1_out = mem_write_reg_data_in;  
      // 如果指令译码的结果需要读reg1，就说明操作数1来自寄存器（rs）
      end else if (reg1_read_enable_out == `Enable) begin
        data1_out = reg1_data_in;
      // 如果指令译码的结果不需要读reg1，就说明操作数1是立即数
      end else if (reg1_read_enable_out == `Disable) begin
        data1_out = immed;
      // 兜底
      end else begin
        data1_out = `ZeroWord;
      end
    end
  
    // 逻辑同上
    always @(*) begin
      if (rst == `Enable) begin
        data2_out = `ZeroWord;
      end else if (ex_write_reg_enable_in == `Enable && reg2_read_enable_out == `Enable && reg2_read_addr_out == ex_write_reg_addr_in) begin
        data2_out = ex_write_reg_data_in;
      end else if (mem_write_reg_enable_in == `Enable && reg2_read_enable_out == `Enable && reg2_read_addr_out == mem_write_reg_addr_in) begin
        data2_out = mem_write_reg_data_in;  
      end else if (reg2_read_enable_out == `Enable) begin //（rt）
        data2_out = reg2_data_in;
      end else if (reg2_read_enable_out == `Disable) begin
        data2_out = immed;
      end else begin
        data2_out = `ZeroWord;
      end
    end

endmodule












