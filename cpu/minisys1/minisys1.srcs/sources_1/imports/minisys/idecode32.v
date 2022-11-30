`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module Idecode32(read_data_1,read_data_2,Instruction,read_data,ALU_result,
                 Jal,RegWrite,MemtoReg,RegDst,Sign_extend,clock,reset,
                 opcplus4,read_register_1_address);
  output[31:0] read_data_1;
  output[31:0] read_data_2;
  input[31:0]  Instruction;
  input[31:0]  read_data;   				//  从DATA RAM or I/O port取出的数据
  input[31:0]  ALU_result;   				//  需要扩展立即数到32位
  input        Jal; 
  input        RegWrite;
  input        MemtoReg;
  input        RegDst;
  output[31:0] Sign_extend;
  input		 clock,reset;
  input[31:0]  opcplus4;                 // 来自取指单元，JAL中用
  output[4:0] read_register_1_address;
  
  wire[31:0] read_data_1;
  wire[31:0] read_data_2;
  reg[31:0] register[0:31];			   //寄存器组共32个32位寄存器
  reg[4:0] write_register_address;
  reg[31:0] write_data;
  wire[4:0] read_register_2_address;
  wire[4:0] write_register_address_1;
  wire[4:0] write_register_address_0;
  wire[15:0] Instruction_immediate_value;
  wire[5:0] opcode;
  
  assign opcode = Instruction[31:26];
  assign read_register_1_address = Instruction[25:21];
  assign read_register_2_address = Instruction[20:16];
  assign write_register_address_1 = Instruction[15:11];    // rd
  assign write_register_address_0 = Instruction[20:16];    // rt
  assign Instruction_immediate_value = Instruction[15:0];
  assign read_data_1 = register[read_register_1_address];
  assign read_data_2 = register[read_register_2_address];

  wire sign;

  assign sign = (opcode == 6'b001000   /* addi */
                || opcode == 6'b001111 /* lui */
                || opcode == 6'b100011 /* lw */ 
                || opcode == 6'b101011 /* sw */
                || opcode == 6'b000100 /* beq */
                || opcode == 6'b000101 /* bne */
                || opcode == 6'b001010 /* slti */);
  assign Sign_extend = sign ? (opcode != 6'b001111 ? /* sign-ext */ {{16{Instruction[15]}}, Instruction[15:0]} 
                                                   : /* lui*/{Instruction[15:0], 16'h0}) 
                            : /* zero-ext */{16'h0, Instruction[15:0]};

  
  always @* begin  //这个进程指定不同指令下的目标寄存器
    if (Jal) begin
      write_register_address = 5'b11111; // 31
    end else if (RegDst) begin
      write_register_address = write_register_address_1;
    end else begin
      write_register_address = write_register_address_0;
    end
  end

  always @* begin  //这个进程基本上是实现结构图中右下的多路选择器,准备要写的数据
    if (Jal) begin
      write_data = opcplus4;
    end else if (MemtoReg) begin
      write_data = read_data;
    end else if (opcode == 6'b001111) begin
      write_data = Sign_extend;
    end else begin
      write_data = ALU_result;
    end

  end

  integer i;
  always @(posedge clock) begin       // 本进程写目标寄存器
    if(reset==1) begin              // 初始化寄存器组
      for(i=0;i<32;i=i+1) begin 
        register[i] <= i;
      end
    end else if(RegWrite==1) begin  // 注意寄存器0恒等于0
      if (write_register_address != 0) begin
        register[write_register_address] = write_data;
      end
    end
  end
endmodule
