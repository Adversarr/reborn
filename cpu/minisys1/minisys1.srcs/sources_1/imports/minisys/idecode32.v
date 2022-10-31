`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module Idecode32(read_data_1,read_data_2,Instruction,read_data,ALU_result,
                 Jal,RegWrite,MemtoReg,RegDst,Sign_extend,clock,reset,
                 opcplus4,read_register_1_address);
  output[31:0] read_data_1;
  output[31:0] read_data_2;
  input[31:0]  Instruction;
  input[31:0]  read_data;   				//  ��DATA RAM or I/O portȡ��������
  input[31:0]  ALU_result;   				//  ��Ҫ��չ��������32λ
  input        Jal; 
  input        RegWrite;
  input        MemtoReg;
  input        RegDst;
  output[31:0] Sign_extend;
  input		 clock,reset;
  input[31:0]  opcplus4;                 // ����ȡָ��Ԫ��JAL����
  output[4:0] read_register_1_address;
  
  wire[31:0] read_data_1;
  wire[31:0] read_data_2;
  reg[31:0] register[0:31];			   //�Ĵ����鹲32��32λ�Ĵ���
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

  assign sign = (opcode == 6'b000100   /* addi */
                || opcode == 6'b100011 /* lui */
                || opcode == 6'b100011 /* lw */ 
                || opcode == 6'b101011 /* sw */
                || opcode == 6'b000100 /* beq */
                || opcode == 6'b000101 /* bne */
                || opcode == 6'b001010 /* slti */);
  assign Sign_extend = sign ? {{16{Instruction[15]}}, Instruction[15:0]} 
                            : {16'h0, Instruction[15:0]};

  
  always @* begin  //�������ָ����ָͬ���µ�Ŀ��Ĵ���
    if (Jal) begin
      write_register_address = 5'b11111; // 31
    end else if (RegDst) begin
      write_register_address = write_register_address_1;
    end else begin
      write_register_address = write_register_address_0;
    end
  end

  always @* begin  //������̻�������ʵ�ֽṹͼ�����µĶ�·ѡ����,׼��Ҫд������
    if (Jal) begin
      write_data = opcplus4;
    end else if (MemtoReg) begin
      write_data = read_data;
    end else begin
      write_data = ALU_result;
    end

  end

  integer i;
  always @(posedge clock) begin       // ������дĿ��Ĵ���
    if(reset==1) begin              // ��ʼ���Ĵ�����
      for(i=0;i<32;i=i+1) begin 
        register[i] <= i;
      end
    end else if(RegWrite==1) begin  // ע��Ĵ���0�����0
      if (write_register_address != 0) begin
        register[write_register_address] = write_data;
      end
    end
  end
endmodule
