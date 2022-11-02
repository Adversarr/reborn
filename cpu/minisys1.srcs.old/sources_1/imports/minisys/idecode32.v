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
    input        MemorIOtoReg;
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
    

    wire sign;

    
    always @* begin                                            //这个进程指定不同指令下的目标寄存器

    end
    
    always @* begin  //这个进程基本上是实现结构图中右下的多路选择器,准备要写的数据
 
     end
    
    integer i;
    always @(posedge clock) begin       // 本进程写目标寄存器
        if(reset==1) begin              // 初始化寄存器组
            for(i=0;i<32;i=i+1) register[i] <= i;
        end else if(RegWrite==1) begin  // 注意寄存器0恒等于0


        end
    end
endmodule
