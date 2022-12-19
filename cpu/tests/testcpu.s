.data
  NUM1:  	.word 0x00000055
  NUM2:  	.word 0x000000AA
  NUM3:  	.word 0x00000000
.text
start:
  lui   $1,0xFFFF
  ori $28,$1,0xF000
k1:
  lw $2,NUM1($0)    # $2 = 0x0000 0055
  lw $3,NUM2($0)      # $3 = 0x0000 00AA
  add $1,$2,$3        # stall, $1 = 0x0000 00FF
  sw $1,NUM3($0)      # num3 = 0x0000 00FF
  subu $4,$3,$2       # $4 = 0x0000 0055
  slt $4,$2,$1        # $4 = 1
  and $1,$3,$7        # $1 = 0x0000 00AA & 0x0000 0007 = 0x0000 0002
  or $6,$2,$1         # $6 = 0x0000 0057
  xor $7,$2,$3        # $7 = 0x0000 00FF
  nor $6,$5,$1        # $6 = 0xFFFF FFF8
  beq $3,$2,-4        # no branch!
gh:	
  sub $2,$2,$5      # $2 = 0x0000 0050
  sw   $2, 0xC50($28) # MEM[0xFFFF FC50] = $2 = 0x0000 0050
  bne $5,$2,gh        # $2 == $5 => continue, (loop $2 -= 5 until $2 == $5 == 5)
  nop                 # pc = 0x0044
  beq $1,$1,ty        # 48: 
  nop                 # 4c:
ty:
  jal jj              # 50
  nop                 # 54
  j mm
  nop
jj:
  jr $31
  nop
mm:
  addi $2,$0,0x99
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
