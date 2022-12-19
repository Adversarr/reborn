.data

  NUM1:  	.word  0x00000055
  NUM2:  	.word  0x000000AA
  NUM3:  	.word  0x00000000
.text

start:lui   $1,0xFFFF
  ori   $28,$1,0xF000
  ori   $1,$0,0xFF0F
  sw   $1, 0xC04($28)
  lw   $2,NUM1($0)
  lw   $3,NUM2($0)
  add $1,$2,$3
  sw   $1, 0xC00($28)
  srl  $1,$1,16
    sw  $1,0xC02($28)
  sw   $2, 0xC50($28)
  addi $2,$0,0x0A
  sw $2,0xC30($28)
  addi $2,$0,1
  sw $2,0xC32($28)
  addi $2,$0,1
  sw $2,0xC34($28)
k1:	addi $2,$0,2
  sw $2,0xC20($28)
  addi $2,$0,7
  sw $2,0xC24($28)
  sw   $2, 0xC50($28)
  nop
  nop


delay:or  $2,$zero,$zero
  lw  $2, 0xC12($28)
  ori  $1, $zero,1
  sw   $2, 0xC50($28)
  bne $2,$1, delay
  or  $2,$zero,$zero
  lw  $2, 0xC10($28)
  sw  $2, 0xC00($28)
  nop
  nop
  nop
  nop
  j k1
