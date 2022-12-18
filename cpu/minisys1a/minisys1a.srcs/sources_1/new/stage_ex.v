// ex.v
// 2020-11 @ https://github.com/seu-cs-class2/minisys-1a-cpu

`include "public.v"

// 指令执行模块
module ex (

  input rst,
  input wire[`ALUOpRange] aluop_in,
  input wire[`WordRange] data1_in,  // �?般是rs
  input wire[`WordRange] data2_in,  // �?般是rt
  input wire[`RegRangeLog2] wreg_addr_in,
  input wire wreg_e_in,

  output reg[`RegRangeLog2] wreg_addr_out,
  output reg wreg_e_out,
  output reg[`WordRange] wreg_data_out,

  input wire[`WordRange] hi_data_in,  // 此条指令（译码阶段）hi给出的结�?
  input wire[`WordRange] lo_data_in,  // lo给出的结�?
  input wire mem_hilo_we_in, // 目前处于访存阶段的hi,lo的写使能（即此条指令的上�?条指令）
  input wire[`WordRange] mem_hi_data_in,  // 访存阶段写入hi的�??
  input wire[`WordRange] mem_lo_data_in,  // 访存阶段写入lo的�??
  input wire wb_hilo_we_in,  // 目前处于写回阶段的hilo写使能（即词条指令的上两条指令）
  input wire[`WordRange] wb_hi_data_in,  // 写回阶段写入hi的�??
  input wire[`WordRange] wb_lo_data_in,  // 写回阶段写入lo的�??
  
  output reg hilo_we_out,  // 此条指令是否要写hilo
  output reg[`WordRange] hi_data_out,  // 写入的hi数据
  output reg[`WordRange] lo_data_out,  // 写入的lo数据

  output reg pause_req,

  input wire[`WordRange] link_addr_in, // 保存的返回地�?

  output reg[`WordRange] div_data1_signed,  // 有符号除法的被除�?
  output reg[`WordRange] div_data2_signed, // 有符号除法的除数
  output reg[`WordRange] div_data1_unsigned, // 无符号除法的被除�?
  output reg[`WordRange] div_data2_unsigned, // 无符号除法的除数
  output reg div_data_valid_signed, // 有符号除法数据是否有效（是否�?始除法）
  output reg div_data_valid_unsigned, // 无符号除法数据是否有�?
  input wire[`DivMulResultRange] div_result_signed,  // 结果64�?
  input wire div_result_valid_signed,  // 有符号除法结果是否有效（有效说明除法结束，应该获取结果）
  input wire[`DivMulResultRange] div_result_unsigned, // 结果64�?
  input wire div_result_valid_unsigned, // 无符号除法结果是否有效（有效说明除法结束，应该获取结果）

  output reg[`WordRange] mul_data1,
  output reg[`WordRange] mul_data2,
  output reg mul_type,
  output reg mul_valid,
  input wire [`DivMulResultRange] mul_result,
  input wire mul_result_valid,




  input is_in_delayslot, // 新增的延迟槽信号，代表处于执行阶段的指令是否是延迟槽指令

  input wire[`WordRange] ins_in, // 新增的指令信号，从id阶段�?直传递过�?
  output reg[`ALUOpRange] aluop_out, // 要向访存部分传�?�aluop
  output reg[`WordRange] mem_addr_out, // 要向访存部分传�?�计算出的内存地�?（所有存储相关指令均会用到）
  output reg[`WordRange] mem_data_out, // 要向访存部分传�?�写入内存的数据（store指令才会用到�?

  //cp0相关
  input wire[`WordRange] cp0_data_in,//从cp0读取的数�?  只是用来给�?�用寄存器的
  output reg[4:0] cp0_raddr_out, //直接传给cp0的地�?

  input wire f_mem_cp0_we_in, //当前处在访存阶段的指令是否要写cp0
  input wire[4:0] f_mem_cp0_w_addr, //要写的地�?
  input wire[`WordRange] f_mem_cp0_w_data, //要写入的数据
  input wire f_wb_cp0_we_in,   //同理  当前处在写回阶段的指令是否要写cp0
  input wire[4:0] f_wb_cp0_w_addr, //写入的地�?
  input wire[`WordRange] f_wb_cp0_w_data,  //写入的数�?

  output reg cp0_we_out,    //cp0是否要被写（当前指令 向下传入流水
  output reg[4:0] cp0_waddr_out,  //cp0写地�?   向下传入流水
  output reg[`WordRange] cp0_w_data_out,   //要写入cp0的数�? 向下传入流水


  //新增加的要向下级流水传的数据
  output reg[`WordRange] ins_out,

  //异常相关
  input wire[`WordRange] current_ex_pc_addr_in,
  input wire[`WordRange] abnormal_type_in,
  output reg[`WordRange] abnormal_type_out,
  output reg[`WordRange] current_ex_pc_addr_out,
  
  output reg is_load_mem
);

  wire[`WordRange] alu_res;  // alu的结�?
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
      is_load_mem = `Disable;
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
      mem_addr_out = data1_in + {{16{ins_in[15]}}, ins_in[15:0]};  // 在这里计算是为了让传递的信号少，并且时序逻辑清晰，增加在ex部分的工�?
      aluop_out = aluop_in;
      mem_data_out = data2_in; // 无论是什么存储操作，都会去使用rt的数�?
      wreg_data_out = alu_res;
      abnormal_type_out = abnormal_type_in;
      current_ex_pc_addr_out = current_ex_pc_addr_in;
      is_load_mem = `Disable;
      case (aluop_in)
        `ALUOP_DIV: begin
          if (div_result_valid_signed == `Disable) begin  // 除法尚未结束
            div_data1_signed = data1_in;
            div_data2_signed = data2_in;
            div_data_valid_signed = `Enable;  // 数据有效
            pause_req = `Enable;  // 暂停流水
          end else if (div_result_valid_signed == `Enable) begin  // 除法结束
            div_data1_signed = data1_in;
            div_data2_signed = data2_in;
            div_data_valid_signed = `Disable;  // 数据无效
            pause_req = `Disable;  // 启动流水
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
        `EXOP_LW,
        `EXOP_LH,
        `EXOP_LHU,
        `EXOP_LB,
        `EXOP_LBU: begin
          is_load_mem = `Enable;
        end
      endcase
    end
  end

  always @(*) begin
    if (rst == `Enable) begin
      hi_temp = `ZeroWord;
      lo_temp = `ZeroWord;
    // 解决MEM-EX流水冲突
    end else if (mem_hilo_we_in == `Enable) begin  // 如果上一条指令也在写hilo
      hi_temp = mem_hi_data_in;
      lo_temp = mem_lo_data_in;
    // 解决WB-EX流水冲突
    end else if (wb_hilo_we_in == `Enable) begin  // 如果上两条指令也在写hilo
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
        `EXOP_MFC0: begin //要写入cp0寄存器，得看�?下数据是不是�?新的
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
         hi_data_out = div_result_signed[31:0];  // HI存余数，LO存商
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
