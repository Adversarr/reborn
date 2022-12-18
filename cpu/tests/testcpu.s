.data
	NUM1:  	.word 0x00000055
	NUM2:  	.word 0x000000AA
	NUM3:  	.word 0x00000000
.text
start:lui   $1,0xFFFF
	ori $28,$1,0xF000
k1:	lw $2,NUM1($0)
	lw $3,NUM2($0)
	add $1,$2,$3
	sw $1,NUM3($0)
	subu $4,$3,$2
	slt $4,$2,$1
	and $1,$3,$7
	or $6,$2,$1
	xor $7,$2,$3
	nor $6,$5,$1
	beq $3,$2,-4
gh:	sub $2,$2,$5
	sw   $2, 0xC50($28)
	bne $5,$2,gh
	beq $1,$1,ty
	nop
ty:	jal jj
	j mm
jj:	jr $31
mm:	addi $2,$0,0x99
	ori $3,$0,0x77
	sll $3,$2,4
	srl $3,$2,4
	srlv $3,$2,$1
	lui $6,0x9988
	sra $7,$6,4
	addi $2,$0,0
	sw   $2, 0xC50($28)
	addi $3,$0,2
	sub  $1,$2,$3
	j k1
