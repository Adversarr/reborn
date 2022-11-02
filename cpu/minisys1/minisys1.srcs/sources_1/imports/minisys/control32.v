`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module control32(Opcode,Function_opcode,Alu_resultHigh,Jrn,RegDST,ALUSrc,MemIoToReg,RegWrite, MemRead,MemWrite, IoRead, IoWrite,
    Branch,nBranch,Jmp,Jal,I_format,Sftmd,ALUOp);
    input[5:0]   Opcode;            // 来自取指单元instruction[31..26]
    input[5:0]   Function_opcode;  	// r-form instructions[5..0]
    output       Jrn;       // done.
    output       RegDST;    // done
    output       ALUSrc;            // 决定第二个操作数是寄存器还是立即数
    output       MemIoToReg;
    output       RegWrite;
    output       MemWrite;
    output       Branch;
    output       nBranch;
    output       Jmp;
    output       Jal;
    output       I_format;
    output       Sftmd;
    output       MemRead;
    output       IoRead;
    output       IoWrite;
    output[1:0]  ALUOp;
    input [21:0] Alu_resultHigh;

     
    wire Jmp,I_format,Jal,Branch,nBranch;
    wire R_format,Lw,Sw;
    wire Beq; assign Beq = (Opcode == 6'b000100) ? 1'b1 : 1'b0;
    wire Bne; assign Bne = (Opcode == 6'b000101) ? 1'b1 : 1'b0;
    assign Jal = Opcode == 6'b000011;
    assign Lw  = Opcode == 6'b100011;
    assign Sw  = Opcode == 6'b101011;
    assign I_format = (Opcode[5:3] == 3'b001) ? 1'b1 : 1'b0;
    assign Jrn = (Opcode == 6'b000000 && Function_opcode == 6'b001000) ? 1'b1: 1'b0; 
    // assign RegDST
    assign R_format = (Opcode==6'b000000)? 1'b1:1'b0;    	//--00h 
    assign RegDST = R_format;                               //说明目标是rd，否则是rt
    assign Jmp = (Opcode == 6'b000010) ? 1'b1 : 1'b0;

    // assign RegWrite
    assign RegWrite = (R_format || Lw || Jal || I_format) && !(Jrn);
    assign MemWrite = ((Sw == 1) && 
        (Alu_resultHigh[21:0] != 22'b1111111111111111111111)) ? 1'b1 : 1'b0;
    assign MemRead = Lw && (Alu_resultHigh[21:0] != 22'b1111111111111111111111);
    assign IoWrite = Sw && !MemWrite;
    assign IoRead  = Lw && !MemRead;
    
    
    assign ALUSrc = (I_format || Lw || Sw ) ? 1'b1 : 1'b0;

    assign MemIoToReg = Lw;
    
    assign RegtoMem = Sw;
    
    assign Branch = Beq;
    
    assign nBranch = Bne;
    
    
    assign Sftmd = (R_format && ((Function_opcode == 6'b000000 || Function_opcode == 6'b000010 || Function_opcode == 6'b000011 ||
                                Function_opcode == 6'b000100 || Function_opcode == 6'b000110 || Function_opcode == 6'b000111) ? 1'b1: 1'b0));
    
    assign ALUOp[0] = Bne | Beq;
    assign ALUOp[1] = R_format | I_format;
    
endmodule