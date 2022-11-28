`include "public.v"

module stage_ex(
  input rst,
  input wire[`ALUOpRange] aluop_in,
  input wire[`WordRange] data1_in, // rs
  input wire[`WordRange] data2_in, // rt
  // Reg Write:
  input wire[`RegRangeLog2] reg_write_addr_in,
  input wire reg_write_enable_in,
  output reg[`RegRangeLog2] reg_write_addr_out,
  output reg reg_write_enable_out,
  output reg[`WordRange] reg_write_data_out,

  input wire[`WordRange] hi_data_in,  // mult/div -- hi data input
  input wire[`WordRange] lo_data_in,  // mult/div -- lo data input
  // stage mem -- hi/lo
  input wire mem_hilo_write_enable_in,
  input wire[`WordRange] mem_hi_data_in,
  input wire[`WordRange] mem_lo_data_in,
  // stage wb -- hi/lo
  input wire wb_hilo_write_enable_in,
  input wire[`WordRange] wb_hi_data_in,
  input wire[`WordRange] wb_lo_data_in,
  // whether to write hilo, and the corresponding data.
  output reg hilo_write_enable_out,
  output reg[`WordRange] hi_data_out,
  output reg[`WordRange] lo_data_out,
  // Pipeline Request
  output reg pause_req,

  // Branching
  input wire[`WordRange] link_addr_in, // 保存的返回地址
  
  // Dividing Operation:
  output reg[`WordRange] div_data1_signed,
  output reg[`WordRange] div_data2_signed,
  output reg[`WordRange] div_data1_unsigned,
  output reg[`WordRange] div_data2_unsigned,
  output reg is_div_data_signed_valid, // 有符号除法数据是否有效（是否开始除法）
  output reg is_div_data_unsigned_valid, // 无符号除法数据是否有效
  input wire[`DivMulResultRange] div_result_signed,  // 结果64位
  input wire is_div_result_signed_valid,  // 有符号除法结果是否有效（有效说明除法结束，应该获取结果）
  input wire[`DivMulResultRange] div_result_unsigned, // 结果64位
  input wire is_div_result_unsigned_valid, // 无符号除法结果是否有效（有效说明除法结束，应该获取结果）

  // Multi Operation:
  output reg[`WordRange] mul_data1,
  output reg[`WordRange] mul_data2,
  output reg is_mul_signed,
  output reg mul_valid,
  input wire [`DivMulResultRange] mul_result,
  input wire mul_result_valid,



  // Delay slot
  input is_in_delayslot, // 新增的延迟槽信号，代表处于执行阶段的指令是否是延迟槽指令
  
  // Instruction Input
  input wire[`WordRange] ins_in, // 新增的指令信号，从id阶段一直传递过来
  //新增加的要向下级流水传的数据
  output reg[`WordRange] ins_out,

  // ALU Op Output, to mem stage...
  output reg[`ALUOpRange] aluop_out, // ALU Op -> mem
  output reg[`WordRange] mem_addr_out, // memory data read.
  output reg[`WordRange] mem_data_out, // memory data output.

  // cp0
  input wire[`WordRange] cp0_data_in, // Data from cp0
  output reg[4:0] cp0_raddr_out,      // Data address for cp0
  // cp0 from external stages:
  input wire mem_cp0_write_enable_in, // whether to write cp0(stage mem)
  input wire[4:0] mem_cp0_w_addr_in, // cp0 addr
  input wire[`WordRange] mem_cp0_w_data_in, // cp0 data 
  input wire wb_cp0_write_enable_in,   // whether to write cp0(stage wb)
  input wire[4:0] wb_cp0_w_addr_in, // addr
  input wire[`WordRange] wb_cp0_w_data_in,  //data

  // cp0(this) output
  output reg cp0_write_enable_out,    // cp0 enable output
  output reg[4:0] cp0_waddr_out,  // cp0 write addr 
  output reg[`WordRange] cp0_w_data_out,   // cp0 data.


  // interruption
  input wire[`WordRange] current_ex_pc_addr_in,
  input wire[`WordRange] abnormal_type_in,
  output reg[`WordRange] abnormal_type_out,
  output reg[`WordRange] current_ex_pc_addr_out
);

  wire[`WordRange] alu_res;  // alu的结果
  reg[`WordRange] mov_res;  // 转移指令（如读hi和lo）的结果
  
  reg[`WordRange] hi_temp;  // 暂存hi
  reg[`WordRange] lo_temp;  // 暂存lo


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
      reg_write_enable_out = `Disable;
      pause_req = `Disable;
      is_div_data_signed_valid = `Disable;
      is_div_data_unsigned_valid = `Disable;
      div_data1_signed = `ZeroWord;
      div_data2_signed = `ZeroWord;
      div_data1_unsigned = `ZeroWord;
      div_data2_unsigned = `ZeroWord;
      mem_addr_out = `ZeroWord;
      aluop_out = aluop_in;
      mem_data_out = `ZeroWord;
      reg_write_data_out = `ZeroWord;
      abnormal_type_out = `ZeroWord;
      current_ex_pc_addr_out = `ZeroWord;
    end else begin
      ins_out = ins_in;
      reg_write_enable_out = reg_write_enable_in;
      reg_write_addr_out = reg_write_addr_in;
      pause_req = `Disable;
      is_div_data_signed_valid = `Disable;
      is_div_data_unsigned_valid = `Disable;
      div_data1_signed = `ZeroWord;
      div_data2_signed = `ZeroWord;
      div_data1_unsigned = `ZeroWord;
      div_data2_unsigned = `ZeroWord;
      mul_data1 = `ZeroWord;
      mul_data2 = `ZeroWord;
      mul_valid = `Disable;
      mem_addr_out = data1_in + {{16{ins_in[15]}}, ins_in[15:0]};  // 在这里计算是为了让传递的信号少，并且时序逻辑清晰，增加在ex部分的工作
      aluop_out = aluop_in;
      mem_data_out = data2_in; // 无论是什么存储操作，都会去使用rt的数据
      reg_write_data_out = alu_res;
      abnormal_type_out = abnormal_type_in;
      current_ex_pc_addr_out = current_ex_pc_addr_in;
      case (aluop_in)
        `ALUOP_DIV: begin
          if (is_div_result_signed_valid == `Disable) begin  // 除法尚未结束
            div_data1_signed = data1_in;
            div_data2_signed = data2_in;
            is_div_data_signed_valid = `Enable;  // 数据有效
            pause_req = `Enable;  // 暂停流水
          end else if (is_div_result_signed_valid == `Enable) begin  // 除法结束
            div_data1_signed = data1_in;
            div_data2_signed = data2_in;
            is_div_data_signed_valid = `Disable;  // 数据无效
            pause_req = `Disable;  // 启动流水
          end
        end
        `ALUOP_DIVU: begin
          if (is_div_result_unsigned_valid == `Disable) begin
            div_data1_unsigned = data1_in;
            div_data2_unsigned = data2_in;
            is_div_data_unsigned_valid = `Enable;
            pause_req = `Enable;
          end else if (is_div_result_unsigned_valid == `Enable) begin
            div_data1_unsigned = data1_in;
            div_data2_unsigned = data2_in;
            is_div_data_unsigned_valid = `Disable;
            pause_req = `Disable;
          end
        end
        `ALUOP_MULT:begin
          if(mul_result_valid == `Disable)begin
            mul_data1 = data1_in;
            mul_data2 = data2_in;
            is_mul_signed = `Enable;
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
            is_mul_signed = `Disable;
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
          reg_write_data_out = link_addr_in;
        end
        `EXOP_MFC0,
        `EXOP_MFLO,
        `EXOP_MFHI:begin
          reg_write_data_out = mov_res;
        end
      endcase
    end
  end

  always @(*) begin
    if (rst == `Enable) begin
      hi_temp = `ZeroWord;
      lo_temp = `ZeroWord;
    // 解决MEM-EX流水冲突
    end else if (mem_hilo_write_enable_in == `Enable) begin  // 如果上一条指令也在写hilo
      hi_temp = mem_hi_data_in;
      lo_temp = mem_lo_data_in;
    // 解决WB-EX流水冲突
    end else if (wb_hilo_write_enable_in == `Enable) begin  // 如果上两条指令也在写hilo
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
        `EXOP_MFC0: begin //要写入cp0寄存器，得看一下数据是不是最新的
          cp0_raddr_out = ins_in[15:11];
          mov_res = cp0_data_in;
          if(mem_cp0_write_enable_in == `Enable && mem_cp0_w_addr_in == ins_in[15:11])begin
            mov_res = mem_cp0_w_data_in;
          end else if(wb_cp0_write_enable_in == `Enable && wb_cp0_w_addr_in == ins_in[15:11]) begin
            mov_res = wb_cp0_w_data_in;
          end
        end
      endcase
    end
  end

  always @(*) begin
    if (rst == `Enable) begin
      hilo_write_enable_out = `Disable;
      hi_data_out = `ZeroWord;
      lo_data_out = `ZeroWord;
    end else begin
      case (aluop_in)
       `ALUOP_DIV: begin
         hilo_write_enable_out = `Enable;
         hi_data_out = div_result_signed[31:0];  // HI存余数，LO存商
         lo_data_out = div_result_signed[63:32];
       end
       `ALUOP_DIVU: begin
         hilo_write_enable_out = `Enable;
         hi_data_out = div_result_unsigned[31:0];
         lo_data_out = div_result_unsigned[63:32];
       end
       `ALUOP_MULT:begin
         hilo_write_enable_out = `Enable;
         hi_data_out = mul_result[63:32];
         lo_data_out = mul_result[31:0];
       end
       `ALUOP_MULTU:begin
         hilo_write_enable_out = `Enable;
         hi_data_out = mul_result[63:32];
         lo_data_out = mul_result[31:0];
       end
       `EXOP_MTHI: begin
          hilo_write_enable_out = `Enable;
          hi_data_out = data1_in;
          lo_data_out = lo_data_in;
       end
       `EXOP_MTLO: begin
          hilo_write_enable_out = `Enable;
          hi_data_out = hi_data_in;
          lo_data_out = data1_in;
       end
      endcase
    end
  end

  always @(*) begin
    if(rst == `Enable)begin
      cp0_write_enable_out = `Disable;
      cp0_waddr_out = 5'b00000;
      cp0_w_data_out = `ZeroWord;
    end else if(aluop_in == `EXOP_MTC0) begin
      cp0_write_enable_out = `Enable;
      cp0_waddr_out = ins_in[15:11];
      cp0_w_data_out = data1_in;
    end else begin
      cp0_write_enable_out = `Disable;
      cp0_waddr_out = 5'b00000;
      cp0_w_data_out = `ZeroWord;
    end
  end

endmodule
