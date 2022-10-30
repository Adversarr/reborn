`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module control32(Opcode,Function_opcode,Jrn,RegDST,ALUSrc,MemtoReg,RegWrite,MemWrite,Branch,nBranch,Jmp,Jal,I_format,Sftmd,ALUOp);
    input[5:0]   Opcode;            // 来自取指单元instruction[31..26]
    input[5:0]   Function_opcode;  	// r-form instructions[5..0]
    output       Jrn;
    output       RegDST;
    output       ALUSrc;            // 决定第二个操作数是寄存器还是立即数
    output       MemtoReg;
    output       RegWrite;
    output       MemWrite;
    output       Branch;
    output       nBranch;
    output       Jmp;
    output       Jal;
    output       I_format;
    output       Sftmd;
    output[1:0]  ALUOp;
     
    wire Jmp,I_format,Jal,Branch,nBranch;
    wire R_format,Lw,Sw;
    
   
    assign R_format = (Opcode==6'b000000)? 1'b1:1'b0;    	//--00h 
    assign RegDST = R_format;                               //说明目标是rd，否则是rt



endmodule