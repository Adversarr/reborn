// id.v
// 2020-11 @ https://github.com/seu-cs-class2/minisys-1a-cpu

`include "public.v"

// 指令译码模块
// 对指令进行译码，输出包括�??
// 源操作数1、源操作�??2、写入的目的寄存器的运算类型（�?�辑、移位�?�算术）
module id (

  input rst, // 复位
  input wire[`WordRange] pc_in, // 输入的PC值，译码阶段指令地址
  input wire[`WordRange] ins_in, // 输入的指令，即取出的指令

  // 寄存器来向数据相关接�??
  input wire[`WordRange] reg1_data_in, // 输入的寄存器数据1
  input wire[`WordRange] reg2_data_in, // 输入的寄存器数据2
  output reg reg1_ren_out, // 寄存器读使能1
  output reg reg2_ren_out, // 寄存器读使能2
  output reg[`RegRangeLog2] reg1_addr_out, // 寄存器读地址1
  output reg[`RegRangeLog2] reg2_addr_out, // 寄存器读地址2

  // 告诉执行单元应执行何种操�??
  output reg[`ALUOpRange] exop_out, // 输出的ALUOp

  // �??终决定的数据
  output reg[`WordRange] data1_out, // 输出的数�??1
  output reg[`WordRange] data2_out, // 输出的数�??2
  
  // 寄存器去向相关接�??
  output reg wreg_wen_out, // 写寄存器使能输出
  output reg[`RegRangeLog2] wreg_addr_out, // 写寄存器地址输出

  // 下面部分用于采用数据前推（转移）法解决相�??0条（ID-EX）和相隔1条（ID-MEM）阶段的RAW数据相关
  // EX阶段运算结果（即上条指令�??
  input wire ex_wreg_en_in,
  input wire[`WordRange] ex_wreg_data_in,
  input wire[`RegRangeLog2] ex_wreg_addr_in,
  // MEM阶段运算结果（上两条指令�??
  input wire mem_wreg_en_in,
  input wire[`WordRange] mem_wreg_data_in,
  input wire[`RegRangeLog2] mem_wreg_addr_in,
  
  input wire wb_wreg_en_in,
  input wire[`WordRange] wb_wreg_data_in,
  input wire[`RegRangeLog2] wb_wreg_addr_in,

  output reg pause_req, // 要求进行流水暂停信号

  // 延迟槽相�??
  input wire in_delayslot_in, // 当前要进入（译码阶段）指令是否是延迟槽内指令（必须执行）
  output reg in_delayslot_out,  // 当前要出（译码阶段）指令是否是延迟槽内指令（必须执行�??
  output reg next_in_delayslot_out, // 下条指令是否处是延迟槽内指令（即当前指令是否要跳转）
  
  // 分支相关
  output reg branch_en_out,  // 分支生效信号
  output reg[`WordRange] branch_addr_out, // 分支跳转地址
  output reg[`WordRange] link_addr_out, // 转移指令�??要保存的地址
  
  output reg[`WordRange] ins_out,   // 向流水线后续传�?�的指令 在添加存储指令时�??要用�??

  // 异常相关
  // abnormal_type_out
  // 31...12 预留
  // 11 eret
  // 10 systemcall
  // 9...8 abnormal info
  // 7...0 interrupt info
  output reg[`WordRange] abnormal_type_out,//指令的异常信�??
  output reg[`WordRange] current_id_pc_addr_out, //当前处在译码阶段指令的地�??
  input wire ex_is_load_mem
);

  // 指令的各个可能组�??
  wire[5:0] op = ins_in[`OpRange];
  wire[4:0] rs = ins_in[`RsRange];
  wire[4:0] rt = ins_in[`RtRange];
  wire[4:0] rd = ins_in[`RdRange];
  wire[4:0] shamt = ins_in[`ShamtRange];
  wire[5:0] func = ins_in[`FuncRange];
  wire[15:0] immediate = ins_in[`ImmedRange];
  wire[15:0] offset = ins_in[`OffsetRange];
  wire[25:0] address = ins_in[`AddressRange];

  reg[`WordRange] immed; // 指令中的立即数的扩展结果
  initial begin
    pause_req = `Disable;
  end

  // 指令译码
  always @(*) begin
    // rst时关掉所有使能，清空立即�??
    if (rst == `Enable) begin
      exop_out = `ALUOP_NOP;
      wreg_wen_out = `Disable;
      reg1_ren_out = `Disable;
      reg2_ren_out = `Disable;
      immed = `ZeroWord;
      ins_out = `ZeroWord;
    // 具体译码逻辑
    end else begin
      ins_out = ins_in; // 直接向下传�??
      // 先赋默认值，以免有些指令不需要修改其中一些�?�时出现错误
      exop_out = `ALUOP_NOP; // ALU 没有操作
      // 禁止相关使能
      wreg_wen_out = `Disable;
      reg1_ren_out = `Disable;
      reg2_ren_out = `Disable;
      // �??0�??
      immed = `ZeroWord;
      // 没有分支
      link_addr_out = `ZeroWord;
      next_in_delayslot_out = `Disable;
      branch_en_out = `Disable;
      branch_addr_out = `ZeroWord;
      // 没有异常信息
      abnormal_type_out = `ZeroWord;
      // 把指令地�??�??下传
      current_id_pc_addr_out = pc_in;
      // 根据op翻译
      if (ins_in == 32'd0) begin
        // nop
      end else begin
        // R类指�??
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
          // HILO相关
          // 注意HI/LO不在32个寄存器的GPR中，使能不要给错
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
          // 跳转�??
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
          `FUNC_JALR: begin  // rd<-PC+4，PC<-rs
            wreg_wen_out = `Enable;
            wreg_addr_out = rd;
            reg1_ren_out = `Enable;
            reg1_addr_out = rs;
            reg2_ren_out = `Disable;
            branch_en_out = `Enable;
            branch_addr_out = data1_out;
            // Link操作，保存返回地�??是PC+8
            link_addr_out = pc_in + 32'd8;
            next_in_delayslot_out = `Enable;
            exop_out = `EXOP_JALR;
          end
          //异常相关
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
        // I类或J�??
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
            // 借助rs=$0的特性，可等价如下实�??
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
            wreg_addr_out = `RegCountLog2'd31; // 固定�??$ra
            reg1_ren_out = `Disable;
            reg2_ren_out = `Disable;
            branch_en_out = `Enable;
            branch_addr_out = {4'b0000, address[25:0], 2'b00};
            // Link操作
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
            // 判断�??0�??
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
            // 判断比零小或相等
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
          `OP_BGEZ: begin // bgez, bltz, bgezal, bltzal都有可能
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
          // 访存相关指令
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
            if (rs == 5'b00000) begin // 是mfc0
              wreg_wen_out = `Enable;
              wreg_addr_out = rt;
              exop_out = `EXOP_MFC0;
              reg1_ren_out = `Disable;
              reg2_ren_out = `Disable;
            end
            if (rs == 5'b00100) begin // 是mtc0
              wreg_wen_out = `Disable;
              exop_out = `EXOP_MTC0;
              reg1_ren_out = `Enable;
              reg1_addr_out = rt;
              reg2_ren_out = `Disable;
            end
            if(ins_in[25:0] == 26'b10000000000000000000011000) begin // 是eret指令
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

  // 下面�??始确定�?�到EX的数据具体来自于哪里
  // 这取决于来源是寄存器，还是立即数
  always @(*) begin
    // rst时固定出0x0
    pause_req = `Disable;
    if (rst == `Enable) begin
      data1_out = `ZeroWord;
    // 解决相隔0条（ID-EX）的流水数据相关
    // 如果前面的EX要写的就是后面的ID要读的，则穿透（转发�??
    end else if (ex_wreg_en_in == `Enable && reg1_ren_out == `Enable && reg1_addr_out == ex_wreg_addr_in) begin
      if (ex_is_load_mem) begin
        pause_req = `Enable;
      end else begin
        data1_out = ex_wreg_data_in;
      end
    // 解决相隔1条（ID-MEM）的流水数据相关
    // 如果前面的MEM要写的就是后面的ID要读的，则穿透（转发�??
    end else if (mem_wreg_en_in == `Enable && reg1_ren_out == `Enable && reg1_addr_out == mem_wreg_addr_in) begin
      data1_out = mem_wreg_data_in;
    end else if (wb_wreg_en_in == `Enable && reg1_ren_out == `Enable && reg1_addr_out == wb_wreg_addr_in) begin
      data1_out = wb_wreg_data_in;  
    // 如果指令译码的结果需要读reg1，就说明操作�??1来自寄存器（rs�??
    end else if (reg1_ren_out == `Enable) begin
      data1_out = reg1_data_in;
    // 如果指令译码的结果不�??要读reg1，就说明操作�??1是立即数
    end else if (reg1_ren_out == `Disable) begin
      data1_out = immed;
    // 兜底
    end else begin
      data1_out = `ZeroWord;
    end
  end

  // 逻辑同上
  always @(*) begin
    pause_req = `Disable;
    if (rst == `Enable) begin
      data2_out = `ZeroWord;
    end else if (ex_wreg_en_in == `Enable && reg2_ren_out == `Enable && reg2_addr_out == ex_wreg_addr_in) begin
       if (ex_is_load_mem) begin
         pause_req = `Enable;
       end else begin
         data2_out = ex_wreg_data_in;
      end
    end else if (mem_wreg_en_in == `Enable && reg2_ren_out == `Enable && reg2_addr_out == mem_wreg_addr_in) begin
      data2_out = mem_wreg_data_in;  
    end else if (wb_wreg_en_in == `Enable && reg2_ren_out == `Enable && reg2_addr_out == wb_wreg_addr_in) begin
      data2_out = wb_wreg_data_in;
    end else if (reg2_ren_out == `Enable) begin //（rt�??
      data2_out = reg2_data_in;
    end else if (reg2_ren_out == `Disable) begin
      data2_out = immed;
    end else begin
      data2_out = `ZeroWord;
    end
  end
endmodule
